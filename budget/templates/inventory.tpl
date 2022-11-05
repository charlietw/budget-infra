budget_instance:
 hosts:
   ${ip} 
 vars:
   ansible_ssh_user: ec2-user
   ansible_ssh_private_key_file: ${ssh_keyfile}
   ansible_ssh_extra_args: '-o StrictHostKeyChecking=no'