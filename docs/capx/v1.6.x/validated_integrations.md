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
| CAPX   | CAPI v1.3.x | CAPI v1.4.x | CAPI v1.5.x | CAPI v1.6.x | CAPI v1.7.x | CAPI v1.8.x | CAPI v1.9.x |
|--------|-------------|-------------|-------------|-------------|-------------|-------------|-------------|
| v1.6.x | Yes         | Yes         | Yes         | Yes         | Yes         | Yes         | Yes         |
| v1.5.x | Yes         | Yes         | Yes         | Yes         | Yes         | Yes         | No          |
| v1.4.x | Yes         | Yes         | Yes         | Yes         | Yes         | No          | No          |

See the [Validated Kubernetes Versions](https://cluster-api.sigs.k8s.io/reference/versions.html?highlight=version#supported-kubernetes-versions){target=_blank} page for more information on CAPI validated versions.

### AOS

| CAPX   | 6.5.x (LTS) | 6.6 (STS) | 6.7 (STS) | 6.8 (STS) | 6.10 | 7.0 | 7.3 |
|--------|-------------|-----------|-----------|-----------|------|-----|-----|
| v1.6.x | No          | No        | No        | Yes       | Yes  | Yes | Yes |
| v1.5.x | Yes         | No        | No        | Yes       | Yes  | Yes | Yes |
| v1.4.x | Yes         | No        | No        | Yes       | No   | No  | No  |

### Prism Central

| CAPX   | pc.2022.6 | pc.2022.9 | pc.2023.x | pc.2024.x | pc.7.3 |
|--------|-----------|-----------|-----------|-----------|--------|
| v1.6.x | No        | No        | Yes       | Yes       | Yes    |
| v1.5.x | Yes       | No        | Yes       | Yes       | Yes    |
| v1.4.x | Yes       | No        | Yes       | Yes       | No     |
