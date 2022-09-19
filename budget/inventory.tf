# create an SSH key for ansible to use
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.key.private_key_pem
  filename        = format("%s/%s/%s", abspath(path.root), ".ssh", aws_key_pair.aws_key.key_name)
  file_permission = "0600"
}

resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tpl", {
    ip          = aws_instance.terraform_ec2.public_ip
    ssh_keyfile = local_sensitive_file.private_key.filename
  })
  filename = "../ansible/inventory.yaml"
}

resource "local_file" "ansible_playbook" {
  content = templatefile("playbook.tpl", {
    email  = var.allowed_email
    domain = var.domain_name
  })
  filename = "../ansible/playbook.yaml"
}

resource "random_password" "cookie_secret" {
  length           = 32
  override_special = "-_"
}

resource "local_file" "oauth_proxy_config" {
  content = templatefile("config.tpl", {
    clientId     = var.gcp_client_id
    clientSecret = var.gcp_client_secret
    cookieSecret = random_password.cookie_secret.result
    ssh_keyfile  = local_sensitive_file.private_key.filename
    domain       = var.domain_name
  })
  filename = "../ansible/config.cfg"
}

