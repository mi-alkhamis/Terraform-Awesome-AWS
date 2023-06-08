
resource "aws_iam_group" "iam_group" {
  name = "iam_group"

}
data "aws_iam_policy" "iam_policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"

}

resource "aws_iam_group_policy_attachment" "policy_attachment" {
  group      = aws_iam_group.iam_group.name
  policy_arn = data.aws_iam_policy.iam_policy.arn
}




