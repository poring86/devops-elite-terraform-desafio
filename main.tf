terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.25.2"
    }
  }
}

provider "digitalocean" {
  token = "dop_v1_4de653098a36000bb43ec1041817e027a85ac35a5fe86eca6b5a4d8d03e52153"
}

resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.ssh_key.id]
}

data "digitalocean_ssh_key" "ssh_key" {
  name = var.ssh_key_name
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.25.4-do.0"

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "do_token" {
  default = ""
}

variable "ssh_key_name" {
  default = "jornada"
}

variable "region" {
  default = "nyc1"
}

output "jenkins_ip"{
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "foo" {
  content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
  filename = "kube_config.yaml"
}