# terraform-oci-autoscaling

Terraform module that manages an [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/)
Auto Scaling configuration for an instance pool. It creates a threshold-based policy that
scales the pool out and in on CPU utilization, bounded by minimum and maximum instance
counts.

## Usage

```hcl
module "autoscaling" {
  source = "github.com/moveeeax/terraform-oci-autoscaling"

  compartment_id   = var.compartment_id
  display_name     = "prod-web-autoscaling"
  instance_pool_id = var.instance_pool_id

  capacity = {
    initial = 3
    min     = 2
    max     = 10
  }

  scale_out_threshold = 75
  scale_in_threshold  = 25

  freeform_tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

A runnable example lives in [`examples/basic`](examples/basic).

## Requirements

| Name      | Version  |
|-----------|----------|
| terraform | >= 1.5   |
| oci       | >= 5.0   |

## Inputs

| Name                   | Description                                                       | Type          | Default | Required |
|------------------------|-------------------------------------------------------------------|---------------|---------|:--------:|
| `compartment_id`       | OCID of the compartment in which to create the configuration.     | `string`      | n/a     |   yes    |
| `display_name`         | Human-readable name for the configuration.                        | `string`      | n/a     |   yes    |
| `instance_pool_id`     | OCID of the instance pool the configuration scales.               | `string`      | n/a     |   yes    |
| `cool_down_in_seconds` | Minimum time between scaling actions, in seconds.                 | `number`      | `300`   |    no    |
| `is_enabled`           | Whether the configuration is enabled.                             | `bool`        | `true`  |    no    |
| `capacity`             | Initial, minimum and maximum instance counts.                     | `object(...)` | n/a     |   yes    |
| `scale_out_threshold`  | CPU % above which the pool scales out.                            | `number`      | `80`    |    no    |
| `scale_in_threshold`   | CPU % below which the pool scales in.                             | `number`      | `20`    |    no    |
| `scaling_step`         | Number of instances added/removed per action.                     | `number`      | `1`     |    no    |
| `freeform_tags`        | Free-form tags applied to the configuration.                      | `map(string)` | `{}`    |    no    |
| `defined_tags`         | Defined tags applied to the configuration, keyed `namespace.key`. | `map(string)` | `{}`    |    no    |

## Outputs

| Name           | Description                                        |
|----------------|----------------------------------------------------|
| `id`           | OCID of the auto scaling configuration.            |
| `display_name` | Display name of the configuration.                 |
| `is_enabled`   | Whether the configuration is enabled.              |
| `policy_ids`   | OCIDs of the scaling policies in the configuration.|

## License

[MIT](LICENSE)
