- name: Install requirements
  hosts: budget_instance
  tasks:
  - name: Install docker from amazon-linux-extras
    become: yes
    ansible.builtin.command: amazon-linux-extras install docker -y

  - name: Start docker
    become: yes
    ansible.builtin.systemd:
      state: started
      name: docker

  - name: Install docker python package # so we can use community.docker.*
    become: yes
    ansible.builtin.pip:
      name: docker

  - name: Install boto3 # so we can use amazon aws
    become: yes
    ansible.builtin.pip:
      name: boto3

  - name: Install botocore # so we can use amazon aws
    become: yes
    ansible.builtin.pip:
      name: botocore

  - name: Pull the oauth2 proxy image
    become: yes
    community.docker.docker_image:
      name: quay.io/oauth2-proxy/oauth2-proxy
      source: pull

  - name: Get certificates from certbot
    become: yes
    community.docker.docker_container:
      name: certbot
      image: certbot/certbot
      detach: no # this is required so that we can read the output
      command: certonly --non-interactive --agree-tos -m ${email} --domain ${domain} --dry-run --standalone
      published_ports:
        - 80:80
      volumes:
        - "/etc/letsencrypt:/etc/letsencrypt"
        - "/var/lib/letsencrypt:/var/lib/letsencrypt"
      auto_remove: yes
    register: certificate_output

  - name: Check certificate could be retrieved 
    ansible.builtin.assert:
      that: "certificate_output.status == 0"

  - name: Change certificate directory permissions
    become: yes
    file:
      state: directory
      recurse: yes
      mode: '755'
      path: /etc/letsencrypt/

  - name: Create budget docker network
    become: yes
    community.docker.docker_network:
      name: budget-net
  
  - name: Run nginx sample app
    become: yes
    community.docker.docker_container:
      name: demo-webserver
      image: nginxdemos/hello
      networks:
        - name: budget-net
        
      purge_networks: yes # so that default network is removed
      auto_remove: yes
    register: web_app

  - name: Create directory for oauth2-proxy config files
    file:
      state: directory
      path: docker

  - name: Create authenticated_emails file
    ansible.builtin.template:
      src: authenticated_emails.txt
      dest: docker/authenticated_emails.txt
      mode: '0755'
    vars:
      authenticated_email: ${email}

  - name: Create oauth2 config file
    ansible.builtin.template:
      src: config.cfg
      dest: docker/config.cfg
      mode: '0755'
    vars:
      docker_ip: "{{ web_app.container.NetworkSettings.Networks['budget-net'].IPAddress }}"
  
  - name: Create directory for certificates
    become: yes
    file:
      state: directory
      path: /etc/letsencrypt/live/${domain}/

  - name: Get private key from S3
    become: yes
    amazon.aws.aws_s3:
      bucket: charlietw-certificates
      object: //certs/${domain}/privkey.pem # needs double // for some reason
      dest: /etc/letsencrypt/live/${domain}/privkey.pem
      mode: get

  - name: Get fullchain from S3
    become: yes
    amazon.aws.aws_s3:
      bucket: charlietw-certificates
      object: //certs/${domain}/fullchain.pem
      dest: /etc/letsencrypt/live/${domain}/fullchain.pem
      mode: get

  - name: Run oauth proxy
    become: yes
    community.docker.docker_container:
      name: oauth-proxy
      image: quay.io/oauth2-proxy/oauth2-proxy
      command: oauth2-proxy --config /etc/config.cfg
      published_ports:
        - 80:80
        - 443:443
      networks:
        - name: budget-net
      volumes:
        - "/etc/letsencrypt:/etc/letsencrypt"
      mounts:
        - type: bind
          source: /home/ec2-user/docker
          target: /etc

