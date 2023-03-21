# User Requirements

Cluster API Provider Nutanix Cloud Infrastructure (CAPX) interacts with Nutanix Prism Central (PC) APIs using a Prism Central user account.

CAPX supports two types of PC users:

- Local users: must be assigned the `Prism Central Admin` role.
- Domain users: must be assigned a role that at least has the [Minimum required CAPX permissions for domain users](#minimum-required-capx-permissions-for-domain-users) assigned.

See [Credential Management](./credential_management.md){target=_blank} for more information on how to pass the user credentials to CAPX.

## Minimum required CAPX permissions for domain users

The following permissions are required for Prism Central domain users: 

- Create Category Mapping
- Create Image
- Create Or Update Name Category
- Create Or Update Value Category
- Create Virtual Machine
- Delete Category Mapping
- Delete Image
- Delete Name Category
- Delete Value Category
- Delete Virtual Machine
- Update Category Mapping
- Update Virtual Machine Project
- Update Virtual Machine
- View Category Mapping
- View Cluster
- View Image
- View Name Category
- View Project
- View Subnet
- View Value Category
- View Virtual Machine

!!! note
    The list of permissions has been validated on PC 2022.6 and above.
