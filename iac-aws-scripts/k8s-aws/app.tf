variable "trusted" {}

data "template_file" "app" {
  template = "${file("manifest/service.yaml.tpl")}"

  vars {
    cert    = "${aws_acm_certificate.cert.arn}"
    trusted = "${var.trusted}"
  }
}

resource "local_file" "service" {
  filename = "manifest/service.yaml"
  content  = "${data.template_file.app.rendered}"

  depends_on = [
    "local_file.mapconfig",
    "aws_autoscaling_group.kube",
  ]
}

/*
resource "kubernetes_service" "app" {
  metadata {
    name = "app"

    labels {
      app = "app"
    }

}
  spec {
    selector {
      app = "app"
    }

    port {
      port        = "443"
      target_port = "5000"
    }

    type = "LoadBalancer"
  }
}

locals {
  anno = <<ANNO
service.beta.kubernetes.io/aws-load-balancer-ssl-cert=${aws_acm_certificate.cert.arn} \
service.beta.kubernetes.io/aws-load-balancer-backend-protocol=http
ANNO
}

resource "null_resource" "anno" {
  provisioner "local-exec" {
    command = "kubectl annotate service ${kubernetes_service.app.metadata.0.name} ${local.anno}"
  }

  triggers {
    service = "${kubernetes_service.app.id}"
  }
}
*/

