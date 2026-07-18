output "id" {
  description = "OCID of the auto scaling configuration."
  value       = oci_autoscaling_auto_scaling_configuration.this.id
}

output "display_name" {
  description = "Display name of the auto scaling configuration."
  value       = oci_autoscaling_auto_scaling_configuration.this.display_name
}

output "is_enabled" {
  description = "Whether the auto scaling configuration is enabled."
  value       = oci_autoscaling_auto_scaling_configuration.this.is_enabled
}

output "policy_ids" {
  description = "OCIDs of the scaling policies in the configuration."
  value       = oci_autoscaling_auto_scaling_configuration.this.policies[*].id
}
