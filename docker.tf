# ---------------------------------------------------------------------------------------------------------------------
# docker.tf
# ---------------------------------------------------------------------------------------------------------------------

provider "docker" {}

resource "docker_network" "consul" {
  name   = "consul"
  driver = "bridge"
  ipam_config {
    subnet  = "172.18.0.0/16"
    gateway = "172.18.0.1"
  }
}

provider "consul" {
  address    = "localhost:8500"
  datacenter = "dc1"
}

resource "docker_container" "dev-consul-master" {
  name  = "dev-consul-master"
  image = "consul:latest"
  restart = "no"
  network_mode = "bridge"
  env = [
    "CONSUL_BIND_INTERFACE=eth0",
    "CONSUL_CLIENT_INTERFACE=eth0",
    "CONSUL_DISABLE_PERM_MGMT=consul:latest"
  ]
  ports {
    internal = 8300
    external = 8300
  }
  ports {
    internal = 8301
    external = 8301
  }
  ports {
    internal = 8301
    external = 8301
    protocol = "udp"
  }
  ports {
    internal = 8302
    external = 8302
    protocol = "udp"
  }
  ports {
    internal = 8400
    external = 8400
  }
  ports {
    internal = 8500
    external = 8500
  }
  ports {
    internal = 8600
    external = 8600
    protocol = "udp"
  }
  volumes {
  container_path = "/data"
  host_path      = "/data/docker/consul"
  }
  command = [ "agent", "-server", "-ui", "-node=dev-consul-master", "-bootstrap-expect=1", "-client", "0.0.0.0", "-datacenter=brussels", "-data-dir=/data/docker/consul" ]
}

resource "docker_container" "dev-consul-server" {
  count = 2
  name  = "dev-consul-server.${count.index}"
  image = "consul:latest"
  restart = "no"
  network_mode = "bridge"
  env = [
    "CONSUL_BIND_INTERFACE=eth0",
    "CONSUL_CLIENT_INTERFACE=eth0",
    "CONSUL_DISABLE_PERM_MGMT=consul:latest"
  ]
  volumes {
  container_path = "/data"
  host_path      = "/data/docker/consul${count.index}"
  }
  command = [ "agent", "-server", "-ui", "-node=dev-consul-server.${count.index}", "-datacenter=brussels", "-join", "consul.service.consul", "-data-dir=/data/docker/consul${count.index}" ]
}
