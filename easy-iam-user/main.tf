resource "aws_iam_user" "user-01" {
  name = "user-01"

}

resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.user-01.name
}