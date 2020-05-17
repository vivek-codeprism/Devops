variable "public_key" {
  type = "list"
}

variable "private_key" {}
variable "environment" {}
variable "couchdb_host" {}
variable "couchdb_port" {}
variable "couchdb_user" {}
variable "couchdb_pass" {}
variable "image" {}
variable "prefix" {}
variable "region" {}
variable "size" {}
variable "domain" {}

locals {
  apps          = ["app", "www"]
  app_config    = "app.conf"
  www_config    = "www.conf"
  server_config = "default.js"
  nginx_home    = "/usr/share/nginx/html"    # CentOS path
  yum           = "sudo yum -y -d 1 install"
}

data "template_file" "app_config" {
  template = "${file("${path.module}/config/${local.app_config}.tpl")}"

  vars {
    environment = "${var.environment}"
    nginx_home  = "${local.nginx_home}"
    domain      = "${var.domain}"
  }
}

data "template_file" "www_config" {
  template = "${file("${path.module}/config/${local.www_config}.tpl")}"

  vars {
    environment = "${var.environment}"
    nginx_home  = "${local.nginx_home}"
    domain      = "${var.domain}"
  }
}

data "template_file" "server_config" {
  template = "${file("${path.module}/config/${local.server_config}.tpl")}"

  vars {
    app_host = "${element(local.apps, 0)}.${var.environment}.${var.domain}"
    app_port = 5000
    db_host  = "${var.couchdb_host}"
    db_port  = "${var.couchdb_port}"
    db_user  = "${var.couchdb_user}"
    db_pass  = "${var.couchdb_pass}"
  }
}

data "aws_route53_zone" "zone" {
  name = "${var.domain}"
}

resource "aws_route53_record" "apps" {
  count   = "${length(local.apps)}"
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name    = "${element(local.apps, count.index)}.${var.environment}.${var.domain}"
  type    = "A"
  ttl     = "60"

  records = [
    "${digitalocean_droplet.app.ipv4_address}",
  ]
}

resource "digitalocean_droplet" "app" {
  image              = "${var.image}"
  name               = "${var.prefix}-app"
  region             = "${var.region}"
  size               = "${var.size}"
  ssh_keys           = ["${var.public_key}"]
  private_networking = true

  connection {
    user        = "centos"
    private_key = "${var.private_key}"
  }

  provisioner "file" {
    source      = "${path.module}/artifacts"
    destination = "artifacts"
  }

  provisioner "file" {
    source      = "${path.module}/config"
    destination = "config"
  }

  provisioner "file" {
    content     = "${data.template_file.app_config.rendered}"
    destination = "${local.app_config}"
  }

  provisioner "file" {
    content     = "${data.template_file.www_config.rendered}"
    destination = "${local.www_config}"
  }

  provisioner "file" {
    content     = "${data.template_file.server_config.rendered}"
    destination = "${local.server_config}"
  }

  provisioner "file" {
    content     = "${acme_certificate.cert.certificate_pem}"
    destination = "certificate.pem"
  }

  provisioner "file" {
    content     = "${acme_certificate.cert.private_key_pem}"
    destination = "private_key.pem"
  }

  provisioner "remote-exec" {
    inline = [
      # deps
      "sudo curl -sL https://rpm.nodesource.com/setup_8.x | sudo bash -",
      "${local.yum} nodejs",
      "${local.yum} epel-release",
      "${local.yum} nginx java-1.8.0-openjdk jq mc vim git gcc-c++ make bzip2",

      # apps
      "sudo /usr/sbin/setsebool httpd_can_network_connect true",
      "cd ${local.nginx_home} && sudo mkdir app www && sudo chown centos:centos app www",
      "cd /opt && sudo mkdir c3s-server c3s-server/config && sudo chown -R centos:centos c3s-server && cd ~",
      "sudo cp *.conf /etc/nginx/conf.d && rm *.conf",
      "sudo cp *.pem /etc/ssl && rm *.pem && sudo chown nginx:nginx /etc/ssl/*.pem && sudo chmod 400 /etc/ssl/*.pem",
      "sudo mv ${local.server_config} /opt/c3s-server/config",
      "sudo mv config/c3s-server.service /etc/systemd/system",
      "sudo systemctl daemon-reload",

      # elasticsearch
      "sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch",
      "sudo mv config/*.repo /etc/yum.repos.d",
      "${local.yum} elasticsearch",
      "sudo systemctl enable elasticsearch",
      "sudo systemctl start elasticsearch",

      # couchdb
      "${local.yum} couchdb",
      "tar -xzf artifacts/couchdb.tgz",
      "sudo mv couchdb /var/lib && sudo chown -R couchdb:couchdb /var/lib/couchdb",
      "echo ${var.couchdb_user} = ${var.couchdb_pass} | sudo tee -a /opt/couchdb/etc/local.ini",

      # import es data
      "sudo npm install elasticdump -g",
      "cd artifacts && tar -xzf elasticdump.tgz && chmod +x import.sh && ./import.sh && cd ~",

      # start services
      "sudo systemctl enable couchdb nginx c3s-server",
      "sudo systemctl start nginx couchdb",
    ]
  }
}
