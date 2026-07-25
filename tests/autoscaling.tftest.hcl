# Test-only requirement: `terraform test` with `mock_provider` needs Terraform >= 1.7.
# The module itself still supports >= 1.5 (see versions.tf) — do not raise
# required_version on account of these tests.
#
# Run with: terraform test

mock_provider "oci" {}

variables {
  compartment_id   = "ocid1.compartment.oc1..aaaaaaaaexamplecompartmentaaaaaaaa"
  instance_pool_id = "ocid1.instancepool.oc1.phx.aaaaaaaaexampleinstancepoolaaaa"
  display_name     = "example-autoscaling"

  capacity = {
    initial = 2
    min     = 1
    max     = 5
  }
}

run "defaults_are_coherent" {
  assert {
    condition     = oci_autoscaling_auto_scaling_configuration.this.is_enabled == true
    error_message = "The auto scaling configuration must be enabled by default."
  }

  assert {
    condition     = oci_autoscaling_auto_scaling_configuration.this.cool_down_in_seconds == 300
    error_message = "The default cooldown must be OCI's 300 second floor."
  }

  assert {
    condition     = oci_autoscaling_auto_scaling_configuration.this.auto_scaling_resources[0].type == "instancePool"
    error_message = "The configuration must target an instance pool."
  }

  assert {
    condition     = oci_autoscaling_auto_scaling_configuration.this.policies[0].policy_type == "threshold"
    error_message = "The generated policy must be a threshold policy."
  }
}

run "scale_out_and_scale_in_rules_cannot_both_match" {
  assert {
    condition = one([
      for r in oci_autoscaling_auto_scaling_configuration.this.policies[0].rules :
      r.metric[0].threshold[0].value if r.display_name == "scale-out"
      ]) > one([
      for r in oci_autoscaling_auto_scaling_configuration.this.policies[0].rules :
      r.metric[0].threshold[0].value if r.display_name == "scale-in"
    ])
    error_message = "The scale-out threshold must sit strictly above the scale-in threshold, otherwise the pool oscillates."
  }

  assert {
    condition = one([
      for r in oci_autoscaling_auto_scaling_configuration.this.policies[0].rules :
      r.metric[0].threshold[0].operator if r.display_name == "scale-out"
    ]) == "GT"
    error_message = "The scale-out rule must fire when utilization exceeds its threshold."
  }

  assert {
    condition = one([
      for r in oci_autoscaling_auto_scaling_configuration.this.policies[0].rules :
      r.metric[0].threshold[0].operator if r.display_name == "scale-in"
    ]) == "LT"
    error_message = "The scale-in rule must fire when utilization drops below its threshold."
  }
}

run "scaling_actions_move_in_opposite_directions" {
  variables {
    scaling_step = 2
  }

  assert {
    condition = one([
      for r in oci_autoscaling_auto_scaling_configuration.this.policies[0].rules :
      r.action[0].value if r.display_name == "scale-out"
    ]) == 2
    error_message = "The scale-out action must add scaling_step instances."
  }

  assert {
    condition = one([
      for r in oci_autoscaling_auto_scaling_configuration.this.policies[0].rules :
      r.action[0].value if r.display_name == "scale-in"
    ]) == -2
    error_message = "The scale-in action must remove scaling_step instances."
  }
}

# --- Configurations that would apply cleanly but never do anything ----------

run "rejects_scale_out_threshold_that_can_never_be_reached" {
  command = plan

  variables {
    scale_out_threshold = 120
  }

  expect_failures = [var.scale_out_threshold]
}

run "rejects_scale_in_threshold_that_can_never_be_reached" {
  command = plan

  variables {
    scale_in_threshold = 0
  }

  expect_failures = [var.scale_in_threshold]
}

run "rejects_inverted_thresholds_that_would_oscillate" {
  command = plan

  variables {
    scale_out_threshold = 20
    scale_in_threshold  = 80
  }

  expect_failures = [oci_autoscaling_auto_scaling_configuration.this]
}

run "rejects_equal_thresholds_that_would_oscillate" {
  command = plan

  variables {
    scale_out_threshold = 50
    scale_in_threshold  = 50
  }

  expect_failures = [oci_autoscaling_auto_scaling_configuration.this]
}

run "rejects_zero_scaling_step" {
  command = plan

  variables {
    scaling_step = 0
  }

  expect_failures = [var.scaling_step]
}

run "rejects_negative_scaling_step" {
  command = plan

  variables {
    scaling_step = -1
  }

  expect_failures = [var.scaling_step]
}

# --- Bounds and identifiers -------------------------------------------------

run "rejects_capacity_min_above_max" {
  command = plan

  variables {
    capacity = {
      initial = 3
      min     = 5
      max     = 2
    }
  }

  expect_failures = [var.capacity]
}

run "rejects_initial_capacity_outside_bounds" {
  command = plan

  variables {
    capacity = {
      initial = 9
      min     = 1
      max     = 5
    }
  }

  expect_failures = [var.capacity]
}

run "rejects_fractional_capacity" {
  command = plan

  variables {
    capacity = {
      initial = 2.5
      min     = 1
      max     = 5
    }
  }

  expect_failures = [var.capacity]
}

run "rejects_cooldown_below_oci_floor" {
  command = plan

  variables {
    cool_down_in_seconds = 60
  }

  expect_failures = [var.cool_down_in_seconds]
}

run "rejects_non_ocid_compartment_id" {
  command = plan

  variables {
    compartment_id = "my-compartment"
  }

  expect_failures = [var.compartment_id]
}

run "rejects_wrong_ocid_type_for_instance_pool" {
  command = plan

  variables {
    instance_pool_id = "ocid1.instance.oc1.phx.aaaaaaaaexampleinstanceaaaaaaaaaa"
  }

  expect_failures = [var.instance_pool_id]
}

run "accepts_tenancy_ocid_as_root_compartment" {
  variables {
    compartment_id = "ocid1.tenancy.oc1..aaaaaaaaexampletenancyaaaaaaaaaaa"
  }

  assert {
    condition     = oci_autoscaling_auto_scaling_configuration.this.compartment_id == "ocid1.tenancy.oc1..aaaaaaaaexampletenancyaaaaaaaaaaa"
    error_message = "A tenancy OCID must be accepted as the root compartment."
  }
}

run "rejects_empty_display_name" {
  command = plan

  variables {
    display_name = "   "
  }

  expect_failures = [var.display_name]
}
