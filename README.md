# terraform-oci-autoscaling

Terraform module that manages an [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/)
Auto Scaling configuration for an instance pool. It creates a threshold-based policy that
scales the pool out and in on CPU utilization, bounded by minimum and maximum instance
counts.

## Usage

```hcl
module "autoscaling" {
  source = "github.com/moveeeax/terraform-oci-autoscaling?ref=v1.0.0"

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

| Name      | Version        |
|-----------|----------------|
| terraform | >= 1.5         |
| oci       | >= 5.0, < 9.0  |

Running the test suite additionally requires Terraform >= 1.7 for `mock_provider`.

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

## Validation

A misconfigured threshold policy still applies cleanly — OCI accepts it and it
simply never does anything useful. The module therefore rejects the following at
plan time rather than letting you find out in production:

| Rule | Why |
|------|-----|
| `scale_out_threshold` must be greater than `scale_in_threshold` | If they overlap or are equal, both rules match at the same CPU utilization and the pool oscillates between scaling out and scaling in. |
| `scale_out_threshold` and `scale_in_threshold` must be within `0 < x < 100` | These are CPU utilization percentages. A scale-out threshold of `100` or more can never be exceeded, and a scale-in threshold of `0` or less can never be undercut, so that rule never fires. |
| `scaling_step` must be a whole number >= 1 | `0` produces a policy that applies successfully but never changes the pool size. A negative value swaps the scale-out and scale-in actions. |
| `capacity` must satisfy `min <= initial <= max`, be whole numbers, and have `max >= 1` | An `initial` outside the bounds or a `max` of `0` leaves the pool in a state the policy cannot correct. |
| `cool_down_in_seconds` must be a whole number >= 300 | OCI enforces a 300 second floor, and shorter cooldowns cause the pool to thrash. |
| `compartment_id` and `instance_pool_id` must be OCIDs of the right type | Catches a region name, display name, or the wrong OCID kind being passed by mistake. `compartment_id` also accepts a tenancy OCID for the root compartment. |

## Testing

```
terraform test
```

The suite runs against a mocked OCI provider, so it needs no credentials and no
network access.

## Outputs

| Name           | Description                                        |
|----------------|----------------------------------------------------|
| `id`           | OCID of the auto scaling configuration.            |
| `display_name` | Display name of the configuration.                 |
| `is_enabled`   | Whether the configuration is enabled.              |
| `policy_ids`   | OCIDs of the scaling policies in the configuration.|

## License

[MIT](LICENSE)
