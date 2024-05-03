# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "region" {
  type    = string
  default = ""
}

variable "application_name" {
  type    = string
  default = ""
}

variable "container_image" {
  description = "Docker image used to start a container"
  type        = string
  default     = ""
}
