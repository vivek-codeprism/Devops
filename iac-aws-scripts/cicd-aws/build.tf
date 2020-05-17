variable "app_repo" {}

resource "aws_instance" "build" {
  instance_type               = "t2.medium"
  ami                         = "${data.aws_ami.ami.image_id}"
  vpc_security_group_ids      = ["${aws_security_group.build.id}"]
  subnet_id                   = "${local.subnet}"
  key_name                    = "${aws_key_pair.key.id}"
  associate_public_ip_address = true
  depends_on                  = ["aws_route.route"]

  tags {
    Name = "build"
  }

  connection {
    user        = "centos"
    private_key = "${file(var.private_key)}"
  }

  provisioner "file" {
    source      = "jenkins"
    destination = "~"
  }

  provisioner "file" {
    source      = "elk.yml"
    destination = "~/elk.yml"
  }

  provisioner "file" {
    source      = "logstash.conf"
    destination = "~/logstash.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "${local.yum} docker git mysql mc",
      "sudo systemctl start docker",
      "sudo mysql -h ${aws_db_instance.db.address} -u ${var.db_user} -p${var.db_pass} -e \"CREATE DATABASE IF NOT EXISTS n5m;\"",
      "sudo git clone ${var.app_repo} && cd n5m/flask",
      "sudo docker build -t n5m .",
      "sudo docker run --name=n5m-db-init -d -e MYSQL_HOST=${aws_db_instance.db.address} n5m python db.py",
      "cd ~/jenkins && sudo docker build -t jenkins .",

      // temporary
      "sudo chmod 777 /var/run/docker.sock",

      "sudo docker run --name jenkins -d -p 8080:8080 -p 50000:50000 -e MYSQL_HOST=${aws_db_instance.db.address} -e ELK=${aws_instance.build.public_dns} -v /var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --log-driver gelf --log-opt gelf-address=udp://localhost:12201 jenkins",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "echo vm.max_map_count=262144 | sudo tee -a /etc/sysctl.conf && sudo sysctl -w vm.max_map_count=262144",
      "sudo /usr/local/bin/docker-compose -f ~/elk.yml up -d",
    ]
  }
}

output "build" {
  value = "${aws_instance.build.public_ip}"
}
