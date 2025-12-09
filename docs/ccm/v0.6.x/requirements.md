# Requirements

Nutanix Cloud Controller Manager (CCM) interacts with Nutanix Prism Central (PC) APIs using a Prism Central user account to fetch the required information for Kubernetes nodes.

CCM supports two types of PC users:

- Local users: automatically get `Viewer` permissions when no role is assigned.
- Domain users: must be assigned a role that includes the `Viewer` role.

## Port requirements

Nutanix CCM uses Prism Central APIs to communicate with the Prism Central endpoint configured in the `nutanix-config` configmap. The following network connectivity is required:

|Source            |Destination         |Protocol  |Port |Description                             |
|------------------|--------------------|----------|-----|----------------------------------------|
|Kubernetes nodes  |Prism Central       |TCP       |9440 |Nutanix CCM communication to Prism Central|

## User permissions

Nutanix CCM performs read-only operations and requires minimal permissions to consume Prism Central APIs.

### Required permissions for local users

Local users automatically receive the necessary permissions:

- View Cluster
- View Category
- View Host
- View Virtual Machine

!!! note
    For local users, if no role is assigned, the local user will only get `Viewer` permissions, which are sufficient for CCM operations.

### Required permissions for domain users

The following role must be assigned for Prism Central domain users:

- Viewer

!!! note
    Domain users must be explicitly assigned the `Viewer` role in the user role-mapping configuration.
