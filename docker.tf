# ---------------------------------------------------------------------------------------------------------------------
# docker.tf
# ---------------------------------------------------------------------------------------------------------------------

provider "docker" {}

resource "docker_container" "dev-consul-master" {
  name  = "dev-consul-master"
  image = "consul:latest"
  restart = "no"
  network_mode = "bridge"
  env = [ "CONSUL_BIND_INTERFACE=eth0"
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
  internal = 53
  external = 8600
  protocol = "udp"
}
}

resource "docker_container" "dev-consul-server" {
  count = 2
  name  = "dev-consul-server.${count.index}"
  image = "consul:latest"
  restart = "no"
  network_mode = "bridge"
  env = [
    "CONSUL_BIND_INTERFACE=eth0"
  ]
  command = [ "agent", "-dev", "-join=${docker_container.dev-consul-master.ip_address}" ]
}
