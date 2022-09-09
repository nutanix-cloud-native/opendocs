# Validated Integrations

Validated integrations are a defined set of specifically tested configurations between technologies that represent the most common combinations that Nutanix customers are using or deploying with CAPX. For these integrations, Nutanix has directly, or through certified partners, exercised a full range of platform tests as part of the product release process.

## Integration Validation Policy

Nutanix follows the version validation policies below:

- Validate at least one active AOS LTS (long term support) version. Validated AOS LTS version for a specific CAPX version is listed in the [AOS](#aos) section.<br>

    !!! note

        Typically the latest LTS release at time of CAPX release except when latest is initial release in train (eg x.y.0). Exact version depends on timing and customer adoption.

- Validate the latest AOS STS (short term support) release at time of CAPX release.
- Validate at least one active Prism Central (PC) version. Validated PC version for a specific CAPX version is listed in the [Prism Central](#prism-central) section.<br>

    !!! note

        Typically the the latest PC release at time of CAPX release except when latest is initial release in train (eg x.y.0). Exact version depends on timing and customer adoption.

- At least one active Cluster-API (CAPI) version. Validated CAPI version for a specific CAPX version is listed in the [Cluster-API](#cluster-api) section.<br>

    !!! note

        Typically the the latest Cluster-API release at time of CAPX release except when latest is initial release in train (eg x.y.0). Exact version depends on timing and customer adoption.

## Validated versions
### Cluster-API
|CAPX  |CAPI<br>v1.1.4|CAPI<br>v1.2.x|
|------|--------------|--------------|
|v0.4.0|Yes           |Yes           |

See the [Validated Kubernetes Versions](https://cluster-api.sigs.k8s.io/reference/versions.html?highlight=version#validated-kubernetes-versions){target=_blank} page for more information on CAPI validated versions.

### AOS

|CAPX  |5.20.4.5 (LTS)|6.1.1.5 (STS)|
|------|--------------|-------------|
|v0.4.0|Yes           |Yes          |


### Prism Central

|CAPX  |2022.1.0.2|pc.2022.6|
|------|----------|---------|
|v0.4.0|Yes       |Yes      |
