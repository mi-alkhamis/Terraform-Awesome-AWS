
resource "aws_key_pair" "ssh_key" {
  key_name   = "aws_ssh_key"
  public_key = tls_private_key.ssh_key_pair.public_key_openssh

}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "ED25519"
  rsa_bits  = 4096
}

resource "local_file" "aws_ssh_private_key_file" {
  filename        = "id_ed25519.key"
  content         = tls_private_key.ssh_key_pair.private_key_openssh
  file_permission = "0600" # file permission for ssh.key file

}

resource "aws_instance" "my_instance" {

  ami           = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name = "My_Instance"
  }
}