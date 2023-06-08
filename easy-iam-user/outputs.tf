output "aws_iam_user_access_key_id" {
  value = aws_iam_access_key.access_key.id

}

output "aws_iam_user_seceret_access_key" {
  value     = aws_iam_access_key.access_key.secret
  sensitive = true
}