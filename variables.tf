variable "compartment_id" {
  description = "OCID of the compartment in which to create the auto scaling configuration."
  type        = string
}

variable "display_name" {
  description = "Human-readable name for the auto scaling configuration."
  type        = string
}

variable "instance_pool_id" {
  description = "OCID of the instance pool the configuration scales."
  type        = string
}

variable "cool_down_in_seconds" {
  description = "Minimum time between scaling actions, in seconds."
  type        = number
  default     = 300

  validation {
    condition     = var.cool_down_in_seconds >= 300
    error_message = "cool_down_in_seconds must be at least 300."
  }
}

variable "is_enabled" {
  description = "Whether the auto scaling configuration is enabled."
  type        = bool
  default     = true
}

variable "capacity" {
  description = "Initial, minimum and maximum instance counts for the pool."
  type = object({
    initial = number
    min     = number
    max     = number
  })

  validation {
    condition     = var.capacity.min <= var.capacity.initial && var.capacity.initial <= var.capacity.max
    error_message = "capacity must satisfy min <= initial <= max."
  }
}

variable "scale_out_threshold" {
  description = "CPU utilization percentage above which the pool scales out."
  type        = number
  default     = 80
}

variable "scale_in_threshold" {
  description = "CPU utilization percentage below which the pool scales in."
  type        = number
  default     = 20
}

variable "scaling_step" {
  description = "Number of instances added or removed per scaling action."
  type        = number
  default     = 1
}

variable "freeform_tags" {
  description = "Free-form tags applied to the auto scaling configuration."
  type        = map(string)
  default     = {}
}

variable "defined_tags" {
  description = "Defined tags applied to the auto scaling configuration, keyed as \"namespace.key\"."
  type        = map(string)
  default     = {}
}
