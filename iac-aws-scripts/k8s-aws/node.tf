data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-v*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon EKS AMI Account ID
}

locals {
  kube-node-userdata = <<USERDATA
#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${aws_eks_cluster.kube.endpoint}' --b64-cluster-ca '${aws_eks_cluster.kube.certificate_authority.0.data}' 'kube'
USERDATA
}

resource "aws_launch_configuration" "kube" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.kube-node.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${local.size}"
  name_prefix                 = "terraform-eks-kube"
  security_groups             = ["${aws_security_group.kube-node.id}"]
  user_data_base64            = "${base64encode(local.kube-node-userdata)}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "kube" {
  desired_capacity     = 1
  launch_configuration = "${aws_launch_configuration.kube.id}"
  max_size             = 1
  min_size             = 1
  name                 = "terraform-eks-kube"
  vpc_zone_identifier  = ["${data.aws_subnet_ids.subnet.ids}"]

  tag {
    key                 = "Name"
    value               = "terraform-eks-kube"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/kube"
    value               = "owned"
    propagate_at_launch = true
  }

  depends_on = [
    "aws_security_group_rule.kube-cluster-ingress-workstation-https",
    "aws_security_group_rule.kube-cluster-ingress-node-https",
    "aws_security_group_rule.kube-node-ingress-self",
    "aws_security_group_rule.kube-node-ingress-cluster",
    "aws_iam_role_policy_attachment.kube-node-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.kube-node-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.kube-node-AmazonEC2ContainerRegistryReadOnly",
  ]
}

resource "aws_iam_role" "kube-node" {
  name = "terraform-eks-kube-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "kube-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.kube-node.name}"
}

resource "aws_iam_role_policy_attachment" "kube-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.kube-node.name}"
}

resource "aws_iam_role_policy_attachment" "kube-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.kube-node.name}"
}

resource "aws_iam_instance_profile" "kube-node" {
  name = "terraform-eks-kube"
  role = "${aws_iam_role.kube-node.name}"
}
