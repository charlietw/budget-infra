bitops_servers:
 hosts:
   ${ip} 
 vars:
   ansible_ssh_user: ec2-user
   ansible_ssh_private_key_file: ${ssh_keyfile}