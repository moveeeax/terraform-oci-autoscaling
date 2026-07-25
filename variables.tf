variable "compartment_id" {
  description = "OCID of the compartment in which to create the auto scaling configuration."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.(compartment|tenancy)\\.", var.compartment_id))
    error_message = "compartment_id must be a compartment or tenancy OCID (starting with \"ocid1.compartment.\" or \"ocid1.tenancy.\")."
  }
}

variable "display_name" {
  description = "Human-readable name for the auto scaling configuration."
  type        = string

  validation {
    condition     = length(trimspace(var.display_name)) > 0
    error_message = "display_name must not be empty."
  }
}

variable "instance_pool_id" {
  description = "OCID of the instance pool the configuration scales."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.instancepool\\.", var.instance_pool_id))
    error_message = "instance_pool_id must be an instance pool OCID (starting with \"ocid1.instancepool.\")."
  }
}

variable "cool_down_in_seconds" {
  description = "Minimum time between scaling actions, in seconds. OCI enforces a floor of 300."
  type        = number
  default     = 300

  validation {
    condition     = var.cool_down_in_seconds >= 300 && floor(var.cool_down_in_seconds) == var.cool_down_in_seconds
    error_message = "cool_down_in_seconds must be a whole number of at least 300; shorter cooldowns are rejected by OCI and cause the pool to thrash."
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

  validation {
    condition = alltrue([
      for v in [var.capacity.initial, var.capacity.min, var.capacity.max] : floor(v) == v && v >= 0
    ])
    error_message = "capacity.initial, capacity.min and capacity.max must be whole numbers greater than or equal to 0."
  }

  validation {
    condition     = var.capacity.max >= 1
    error_message = "capacity.max must be at least 1; a maximum of 0 leaves the pool permanently empty."
  }
}

variable "scale_out_threshold" {
  description = "CPU utilization percentage above which the pool scales out. Must be greater than scale_in_threshold."
  type        = number
  default     = 80

  validation {
    condition     = var.scale_out_threshold > 0 && var.scale_out_threshold < 100
    error_message = "scale_out_threshold is a CPU utilization percentage and must be between 0 and 100 exclusive; a value of 100 or more can never be exceeded, so the pool would never scale out."
  }
}

variable "scale_in_threshold" {
  description = "CPU utilization percentage below which the pool scales in. Must be less than scale_out_threshold."
  type        = number
  default     = 20

  validation {
    condition     = var.scale_in_threshold > 0 && var.scale_in_threshold < 100
    error_message = "scale_in_threshold is a CPU utilization percentage and must be between 0 and 100 exclusive; a value of 0 or less can never be undercut, so the pool would never scale in."
  }
}

variable "scaling_step" {
  description = "Number of instances added or removed per scaling action."
  type        = number
  default     = 1

  validation {
    condition     = var.scaling_step >= 1 && floor(var.scaling_step) == var.scaling_step
    error_message = "scaling_step must be a whole number of at least 1; 0 produces a policy that applies successfully but never changes the pool size, and a negative value inverts the scale-out and scale-in actions."
  }
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
