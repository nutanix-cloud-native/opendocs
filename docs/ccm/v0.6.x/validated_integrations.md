# Validated Integrations

Validated integrations are a defined set of specifically tested configurations between technologies that represent the most common combinations that Nutanix customers are using or deploying with Nutanix CCM. For these integrations, Nutanix has directly, or through certified partners, exercised a full range of platform tests as part of the product release process.

## Integration Validation Policy

Nutanix follows the version validation policies below for CCM:

- Validate at least one active AOS LTS (long term support) version. Validated AOS LTS version for a specific CCM version is listed in the [AOS](#aos) section.<br>

    !!! note

        Typically the latest LTS release at time of CCM release except when latest is initial release in train (eg x.y.0). Exact version depends on timing and customer adoption.

- Validate the latest AOS STS (short term support) release at time of CCM release.
- Validate at least one active Prism Central (PC) version. Validated PC version for a specific CCM version is listed in the [Prism Central](#prism-central) section.<br>

    !!! note

        Typically the latest PC release at time of CCM release except when latest is initial release in train (eg x.y.0). Exact version depends on timing and customer adoption.

- At least two active Kubernetes versions. Validated Kubernetes versions for a specific CCM version are listed in the [Kubernetes](#kubernetes) section.<br>

    !!! note

        Typically the current stable Kubernetes release and the previous stable release at time of CCM release.

## Validated versions

### AOS

| CCM    | 6.5.x (LTS) | 6.8 (STS) | 6.10 | 7.0 | 7.3 |
|--------|-------------|-----------|------|-----|-----|
| v0.6.x | No          | Yes       | Yes  | Yes | Yes |
| v0.5.x | Yes         | Yes       | Yes  | Yes | Yes |
| v0.4.x | Yes         | Yes       | Yes  | Yes | No  |

### Prism Central

| CCM    | pc.2022.6 | pc.2023.x | pc.2024.x | pc.7.3 |
|--------|-----------|-----------|-----------|--------|
| v0.6.x | No        | No        | No        | Yes    |
| v0.5.x | Yes       | Yes       | Yes       | Yes    |
| v0.4.x | Yes       | Yes       | No        | No     |

### CAPX Integration

| CCM    | CAPX v1.6.x | CAPX v1.7.x | CAPX v1.8.x |
|--------|-------------|-------------|-------------|
| v0.6.x | Yes         | Yes         | Yes         |
| v0.5.x | Yes         | Yes         | Yes         |
| v0.4.x | Yes         | Yes         | No          |
