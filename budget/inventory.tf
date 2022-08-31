# create an SSH key for ansible to use
resource "local_sensitive_file" "private_key" {
  content = tls_private_key.key.private_key_pem
  filename          = format("%s/%s/%s", abspath(path.root), ".ssh", aws_key_pair.aws_key.key_name)
  file_permission   = "0600"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl", {
      ip          = aws_instance.terraform_ec2.public_ip
      ssh_keyfile = local_sensitive_file.private_key.filename
  })
  filename = format("%s/%s", abspath(path.root), "inventory.yaml")
}