variable "resource-group" {
  default = "docker_hw"
}
variable "location" {
  default = "francecentral"
}

variable "custom_data_loc" {
  default = "scripts/docker-deployment.sh"
}

variable "container_registry_host" {
  default = "host"
}

variable "container_registry_password" {
  default = "password"
}

variable "container_registry_username" {
  default = "username"
}
