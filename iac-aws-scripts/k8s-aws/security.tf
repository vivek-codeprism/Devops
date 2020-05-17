resource "aws_security_group" "kube-cluster" {
  name        = "terraform-eks-kube-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${data.aws_vpcs.vpc.ids[0]}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "terraform-eks-kube"
  }
}

resource "aws_security_group_rule" "kube-cluster-ingress-workstation-https" {
  cidr_blocks       = ["159.100.69.112/28"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.kube-cluster.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group" "kube-node" {
  name        = "terraform-eks-kube-node"
  description = "Security group for all nodes in the cluster"
  vpc_id      = "${data.aws_vpcs.vpc.ids[0]}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${
    map(
     "Name", "terraform-eks-kube-node",
     "kubernetes.io/cluster/kube", "owned",
    )
  }"
}

resource "aws_security_group_rule" "kube-node-ingress-self" {
  description              = "Allow node to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.kube-node.id}"
  source_security_group_id = "${aws_security_group.kube-node.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "kube-node-ingress-cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.kube-node.id}"
  source_security_group_id = "${aws_security_group.kube-cluster.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "kube-cluster-ingress-node-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.kube-cluster.id}"
  source_security_group_id = "${aws_security_group.kube-node.id}"
  to_port                  = 443
  type                     = "ingress"
}
