
resource "aws_key_pair" "aws_key_pair" {
  key_name   = "aws_ssh_key"
  public_key = tls_private_key.ssh_key_pair.public_key_openssh

}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "ED25519"
  rsa_bits = 4096
}

resource "local_file" "aws_ssh_file" {
  filename        = "id_ed25519.key"
  content         = tls_private_key.ssh_key_pair.private_key_openssh
  file_permission = "0600" # file permission for ssh.key file

}