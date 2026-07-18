resource "oci_autoscaling_auto_scaling_configuration" "this" {
  compartment_id       = var.compartment_id
  display_name         = var.display_name
  cool_down_in_seconds = var.cool_down_in_seconds
  is_enabled           = var.is_enabled

  auto_scaling_resources {
    id   = var.instance_pool_id
    type = "instancePool"
  }

  policies {
    display_name = "${var.display_name}-threshold-policy"
    policy_type  = "threshold"

    capacity {
      initial = var.capacity.initial
      min     = var.capacity.min
      max     = var.capacity.max
    }

    rules {
      display_name = "scale-out"
      action {
        type  = "CHANGE_COUNT_BY"
        value = var.scaling_step
      }
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "GT"
          value    = var.scale_out_threshold
        }
      }
    }

    rules {
      display_name = "scale-in"
      action {
        type  = "CHANGE_COUNT_BY"
        value = -var.scaling_step
      }
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "LT"
          value    = var.scale_in_threshold
        }
      }
    }
  }

  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
}
