locals {
  kubeconfig = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${google_container_cluster.kube.master_auth.0.cluster_ca_certificate}
    server: https://${google_container_cluster.kube.endpoint}
  name: kube
contexts:
- context:
    cluster: kube
    user: admin
  name: kube
current-context: kube
kind: Config
preferences: {}
users:
- name: admin
  user:
    client-certificate-data: ${google_container_cluster.kube.master_auth.0.client_certificate}
    client-key-data: ${google_container_cluster.kube.master_auth.0.client_key}
KUBECONFIG
}

resource "google_container_cluster" "kube" {
  provider           = "google-beta"
  name               = "kube"
  zone               = "us-central1-a"
  initial_node_count = 1

  enable_legacy_abac = true

  min_master_version = "1.11"

  cluster_autoscaling {
    enabled = true

    resource_limits {
      resource_type = "cpu"
      maximum       = "10"
    }

    resource_limits {
      resource_type = "memory"
      maximum       = "16"
    }
  }

  master_auth {
    username = ""
    password = ""
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "local_file" "kubeconfig" {
  content  = "${local.kubeconfig}"
  filename = "${pathexpand("~/.kube/config")}"
}
