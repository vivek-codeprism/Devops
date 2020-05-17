data "aws_vpcs" "vpc" {}

data "aws_subnet_ids" "subnet" {
  vpc_id = "${data.aws_vpcs.vpc.ids[0]}"
}

locals {
  size = "m4.large"

  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.kube.endpoint}
    certificate-authority-data: ${aws_eks_cluster.kube.certificate_authority.0.data}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "kube"
KUBECONFIG

  config_map_aws_auth = <<CONFIGMAPAWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${aws_iam_role.kube-node.arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}

resource "aws_eks_cluster" "kube" {
  name     = "kube"
  role_arn = "${aws_iam_role.kube.arn}"

  vpc_config {
    security_group_ids = ["${aws_security_group.kube-cluster.id}"]
    subnet_ids         = ["${data.aws_subnet_ids.subnet.ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.kube-cluster",
    "aws_iam_role_policy_attachment.kube-service",
  ]
}

resource "aws_iam_role" "kube" {
  name = "kube"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "kube-cluster" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.kube.name}"
}

resource "aws_iam_role_policy_attachment" "kube-service" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.kube.name}"
}

resource "local_file" "kubeconfig" {
  content  = "${local.kubeconfig}"
  filename = "${pathexpand("~/.kube/config")}"
}

resource "local_file" "mapconfig" {
  content  = "${local.config_map_aws_auth}"
  filename = "${pathexpand("~/.kube/config_map_aws_auth.yaml")}"

  provisioner "local-exec" {
    command = "kubectl apply -f ${pathexpand("~/.kube/config_map_aws_auth.yaml")}"
  }

  depends_on = ["local_file.kubeconfig"]
}
