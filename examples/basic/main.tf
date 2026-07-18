provider "oci" {}

module "autoscaling" {
  source = "../.."

  compartment_id   = var.compartment_id
  display_name     = "example-autoscaling"
  instance_pool_id = var.instance_pool_id

  capacity = {
    initial = 2
    min     = 1
    max     = 5
  }

  freeform_tags = {
    Environment = "sandbox"
    ManagedBy   = "terraform"
  }
}

variable "compartment_id" {
  description = "Compartment OCID to deploy the example configuration into."
  type        = string
}

variable "instance_pool_id" {
  description = "OCID of the instance pool the example configuration scales."
  type        = string
}

output "auto_scaling_configuration_id" {
  value = module.autoscaling.id
}
