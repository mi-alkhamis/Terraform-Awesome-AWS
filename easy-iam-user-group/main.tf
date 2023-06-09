resource "aws_iam_user" "iam_user" {
  name = "user"

}

resource "aws_iam_group" "iam_group" {
  name = "iam_group"
}

resource "aws_iam_user_group_membership" "user_membership" {
  user   = aws_iam_user.iam_user.name
  groups = [aws_iam_group.iam_group.name]


}