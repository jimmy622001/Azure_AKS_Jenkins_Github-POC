# Disaster Recovery (Pilot Light) Environment

This directory contains the Terraform configuration for the Disaster Recovery environment that follows a "pilot light" approach.

## What is a Pilot Light DR Strategy?

The pilot light method is a disaster recovery approach where a minimal version of an environment is always running in the cloud. The term comes from the gas heater analogy where a small flame that's always on can quickly ignite the entire furnace when needed.

In our implementation:
- A small AKS cluster with minimal nodes is maintained
- Database replication is configured from production
- Container images are automatically replicated to the DR region's ACR
- All security controls are in place but with minimal compute resources
- The environment is configured to rapidly scale upon DR activation

## Key Components

1. **Network Infrastructure**: Full VNet setup with subnets matching production topology
2. **Minimal AKS Cluster**: Small node count but with autoscaling configured for rapid expansion
3. **Database Replication**: Geo-replicated databases from production
4. **Jenkins VM**: Smaller VM for CI/CD that can be scaled up during DR
5. **Security Controls**: Full security implementation matching production

## DR Activation

To activate the DR environment in case of a primary region failure:

1. Update the `terraform.tfvars` file:
   ```
   is_active = true
   ```

2. Apply the Terraform configuration:
   ```
   terraform apply
   ```

3. The environment will automatically scale up to handle production workloads.

4. Follow the detailed steps in the [DR Plan](/docs/DR_PLAN.md).

## Regular Testing

The DR environment should be tested regularly according to the schedule and procedures defined in the DR plan:

1. Quarterly failover tests (partial)
2. Bi-annual complete failover simulation
3. Monthly replication validation

## Monitoring

The DR environment includes monitoring specifically for:

- Replication status between primary and DR
- Pilot light health checks
- Readiness for activation metrics

## Cost Management

The pilot light approach balances DR readiness with cost efficiency:

- Minimal compute resources during normal operation
- Automated scaling during DR events
- Reserved instances for core components
- Cost optimization for idle resources

## Security

See [SECURITY.md](SECURITY.md) for DR environment security guidelines.