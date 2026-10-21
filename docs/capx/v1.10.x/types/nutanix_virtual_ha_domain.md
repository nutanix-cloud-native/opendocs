# NutanixVirtualHADomain

!!! warning
    The `NutanixMetro`, `NutanixMetroSite` and `NutanixVirtualHADomain` resources are new in CAPX v1.10.x and are intended for Metro / disaster-recovery topologies.

The `NutanixVirtualHADomain` resource describes the high-availability domain for a [`NutanixMetro`](./nutanix_metro.md). It ties together the protection policy and the movement groups that define which entities move together during a failover or migration, mapping each category to the recovery plan that protects it.

Example of a `NutanixVirtualHADomain` resource:

```YAML
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixVirtualHADomain
metadata:
  name: "${VHA_DOMAIN_NAME}"
  namespace: "${CLUSTER_NAMESPACE}"
spec:
  metroRef:
    name: "${METRO_NAME}"
  # Optional: protection policy applied to the union of all categories across movement groups.
  protectionGroup:
    protectionPolicy:
      type: name
      name: "${PROTECTION_POLICY_NAME}"
  movementGroups:
    default:
      categoryRecoveryPlans:
        - category:
            key: "AppType"
            value: "Kubernetes"
          recoveryPlan:
            type: name
            name: "${RECOVERY_PLAN_NAME}"
          failureDomainRef:
            name: "${FAILURE_DOMAIN_A_NAME}"
```

## NutanixVirtualHADomain spec
The table below provides an overview of the supported parameters of the `spec` attribute of a `NutanixVirtualHADomain` resource.

### Configuration parameters

| Key                                                               |Type  |Description                                                                                             |
|-------------------------------------------------------------------|------|-------------------------------------------------------------------------------------------------------|
|metroRef                                                           |object|**Required.** Reference to the `NutanixMetro` object this virtual HA domain belongs to.                 |
|metroRef.name                                                      |string|Name of the `NutanixMetro` object in the same namespace. Must not be empty.                             |
|protectionGroup                                                    |object|(Optional) Protection policy applied to the union of all categories across the movement groups.         |
|protectionGroup.protectionPolicy                                   |object|**Required** when `protectionGroup` is set. Identifier of the protection policy in Prism Central.       |
|protectionGroup.protectionPolicy.type                              |string|Type to identify the protection policy. Allowed values: `name` and `uuid`.                              |
|protectionGroup.protectionPolicy.name                              |string|Name of the protection policy.                                                                          |
|protectionGroup.protectionPolicy.uuid                              |string|UUID of the protection policy.                                                                          |
|movementGroups                                                     |map   |(Optional) Named groups of entities that move together. The key is a user-defined group name (e.g. `default`). |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans                  |list  |**Required** (min 1). List of category-to-recovery-plan mappings for this movement group.               |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].category      |object|**Required.** The category (key/value) whose member entities are protected.                             |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].category.key  |string|Key of the category in Prism Central.                                                                   |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].category.value|string|Value of the category linked to the category key in Prism Central.                                      |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].recoveryPlan  |object|**Required.** Identifier of the recovery plan associated with the category.                             |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].recoveryPlan.type|string|Type to identify the recovery plan. Allowed values: `name` and `uuid`.                               |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].recoveryPlan.name|string|Name of the recovery plan.                                                                           |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].recoveryPlan.uuid|string|UUID of the recovery plan.                                                                           |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].failureDomainRef|object|**Required.** Reference to the `NutanixFailureDomain` identifying the Prism Element cluster for this mapping. |
|movementGroups.&lt;name&gt;.categoryRecoveryPlans.[].failureDomainRef.name|string|Name of the `NutanixFailureDomain` object. Must not be empty.                                    |

## Usage Notes

- `metroRef` must reference an existing [`NutanixMetro`](./nutanix_metro.md) in the same namespace.
- A **movement group** is a set of entities (identified by categories) that fail over or migrate together. Each movement group maps every category to the recovery plan that protects its member entities on a given Prism Element (identified by `failureDomainRef`).
- The optional `protectionGroup` defines the protection policy that applies to the union of all categories across every movement group.
- A deletion finalizer (`infrastructure.cluster.x-k8s.io/nutanixvirtualhadomain`) blocks deletion while the object is still referenced by other resources.
- The `status.ready` field is set to `true` when the virtual HA domain Prism Central resources (categories, protection policy, and recovery plan) are valid and ready. `status.movementGroups` reports the per-movement-group readiness, and `status.conditions` reflects the latest observed states.
