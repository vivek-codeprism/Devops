variable "backet" {}

resource "aws_iam_user" "env_user" {
  count = "${length(var.account)}"
  name  = "${element(keys(var.account), count.index)}_user"
  path  = "/system/"
}

resource "aws_iam_access_key" "env_key" {
  count = "${length(var.account)}"
  user  = "${aws_iam_user.env_user.*.name[count.index]}"
}

resource "aws_iam_user_policy" "env_policy" {
  count  = "${length(var.account)}"
  name   = "environment_policy"
  user   = "${aws_iam_user.env_user.*.id[count.index]}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${element(values(var.account), count.index)}:role/environment_role",
      "Effect": "Allow"
    },
    {
      "Action": [
        "route53:GetHostedZone",
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets",
        "route53:GetChange"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*",
        "arn:aws:route53:::change/*"
      ],
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_user" "env_backend_user" {
  name = "environment_backend_user"
  path = "/system/"
}

resource "aws_iam_access_key" "env_backend_key" {
  user = "${aws_iam_user.env_backend_user.name}"
}

resource "aws_iam_user_policy" "env_backend_policy" {
  name   = "environment_backend_policy"
  user   = "${aws_iam_user.env_backend_user.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.backet}"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::${var.backet}/*"
    }
  ]
}
EOF
}

output "access_key" {
  value = "${zipmap(keys(var.account), aws_iam_access_key.env_key.*.id)}"
}

output "secret_key" {
  value = "${zipmap(keys(var.account), aws_iam_access_key.env_key.*.secret)}"
}

output "backend_access_key" {
  value = "${aws_iam_access_key.env_backend_key.id}"
}

output "backend_secret_key" {
  value = "${aws_iam_access_key.env_backend_key.secret}"
}
