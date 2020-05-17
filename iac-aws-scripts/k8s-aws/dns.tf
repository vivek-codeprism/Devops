variable "domain" {}
variable "hostname" {}

data "aws_route53_zone" "zone" {
  name = "${var.domain}"
}

data "aws_elb_hosted_zone_id" "zone" {}

/*
resource "null_resource" "hostname" {
  provisioner "local-exec" {
    command = "echo hostname = \"$(kubectl get service app -o=jsonpath='{.status.loadBalancer.ingress[].hostname}')\" > hostname.auto.tfvars"
  }
}

*/
resource "aws_route53_record" "app" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "app.${var.domain}"
  type    = "A"

  alias {
    #    name                   = "${kubernetes_service.app.load_balancer_ingress.0.hostname}"
    name                   = "${var.hostname}"
    zone_id                = "${data.aws_elb_hosted_zone_id.zone.id}"
    evaluate_target_health = true
  }
}
