# User Requirements

Cluster API Provider Nutanix Cloud Infrastructure (CAPX) interacts with Nutanix Prism Central (PC) APIs using a Prism Central user account.

CAPX supports two types of PC users:

- Local users: must be assigned the `Prism Central Admin` role.
- Domain users: must be assigned a role that at least has the [Minimum required CAPX permissions for domain users](#minimum-required-capx-permissions-for-domain-users) assigned.

See [Credential Management](./credential_management.md){target=_blank} for more information on how to pass the user credentials to CAPX.

## Minimum required CAPX permissions for domain users

The following permissions are required for Prism Central domain users: 

- Create Category
- View Cluster Pgpu Profiles
- View Cluster Vgpu Profiles
- Create Image
- Create New Virtual Machine
- Delete Image
- Delete Category
- Delete Virtual Machine
- Detach Volume Group From AHV VM
- Power On Virtual Machine
- Update Virtual Machine Custom Attributes
- View Category
- View Cluster
- View Image
- View Project
- View Subnet
- View Virtual Machine

!!! note
    The list of permissions has been validated on PC 7.3 and above.

!!! note
    To use the [`NutanixMetro`](./types/nutanix_metro.md) resource (and the related `NutanixMetroSite` and `NutanixVirtualHADomain` resources), the Prism Central user must additionally have the **DR Admin** role, as these resources manage disaster-recovery entities such as protection policies and recovery plans.

## CAPX v1.10.x Upgrade Requirements

CAPX v1.10.x does not introduce any new Prism Central permission requirements compared to v1.9.x. When upgrading from v1.9.x to v1.10.x, no additional permissions beyond those already required for v1.9.x need to be granted.

For reference, the complete set of permissions required for Prism Central domain users is: 

- Create Category
- Create Category Mapping
- Create Image
- Create New Virtual Machine
- Create Or Update Name Category
- Create Or Update Value Category
- Create Virtual Machine
- Delete Category
- Delete Category Mapping
- Delete Image
- Delete Name Category
- Delete Value Category
- Delete Virtual Machine
- Detach Volume Group From AHV VM
- Power On Virtual Machine
- Update Virtual Machine Custom Attributes
- View Category
- View Category Mapping
- View Cluster
- View Cluster Pgpu Profiles
- View Cluster Vgpu Profiles
- View Image
- View Name Category
- View Project
- View Subnet
- View Value Category
- View Virtual Machine
