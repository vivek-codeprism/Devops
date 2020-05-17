variable "region" {}
variable "itype" {}

resource "aws_iam_user" "packer_user" {
  name  = "packer_user"
  path  = "/system/"
}

resource "aws_iam_access_key" "packer_key" {
  user  = "${aws_iam_user.packer_user.name}"
}

resource "aws_iam_user_policy" "packer_policy" {
  name   = "packer_policy"
  user   = "${aws_iam_user.packer_user.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "ec2:*",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "ec2:Region": "${var.region}"
        }
      },
      "Effect": "Allow"
    },
    {
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringNotEquals": {
          "ec2:InstanceType": "${var.itype}"
        }
      },
      "Effect": "Deny"
    }
  ]
}
EOF
}

output "packer_access_key" {
  value = "${aws_iam_access_key.packer_key.id}"
}

output "packer_secret_key" {
  value = "${aws_iam_access_key.packer_key.secret}"
}
