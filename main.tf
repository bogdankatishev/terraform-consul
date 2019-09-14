# ---------------------------------------------------------------------------------------------------------------------
# main.tf
# ---------------------------------------------------------------------------------------------------------------------

resource "docker_volume" "consul_data" {
  name = "consul_data"
  driver = "local-persist"
  driver_opts = {
      "mountpoint" = "${var.consul_data_mount}"
  }
}

# Create a new docker network
resource "docker_network" "private_network" {
  name = "dev"
}

resource "docker_service" "consul" {
    name = "consul-service"

    task_spec {
        container_spec {
            image = "consul"

            mounts = {
                          target      = "/var/run/docker.sock"
                          source      = "/var/run/docker.sock"
                          type        = "bind"
                          read_only   = true
                     }

            mounts = {
                          source      = "${docker_volume.consul_data.name}"
                          target      = "/var/consul"
                          type        = "volume"
                          read_only   = false
                     },


        }
        networks     = ["${docker_network.private_network.name}"]
    }

    endpoint_spec {
      ports {
        target_port = "8500"
        published_port = "8500"
      }
    }
}
