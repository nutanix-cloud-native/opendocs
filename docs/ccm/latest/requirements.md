# Requirements

This section will provide an overview of following requirements for Nutanix CCM:

- [Port requirements](#port-requirements)
- [User permissions](#user-permissions)

## Port requirements

Nutanix CCM uses Prism Central APIs to fetch the required information for the Kubernetes nodes. As a result, the Kubernetes nodes need to have access to the Prism Central endpoint that is configured in the `nutanix-config` configmap.

|Source            |Destination         |Protocol  |Port |Description                             |
|------------------|--------------------|----------|-----|----------------------------------------|
|Kubernetes nodes|Prism Central       |TCP       |9440 |Nutanix CCM communication to Prism Central|


## User permissions
Nutanix CCM requires a user account to consume the Prism Central APIs. Nutanix CCM will only perform read operations, hence no create, update or delete permissions are required and a `Viewer` role will suffice.

### Required roles: Local user

|Role               |Required|
|-------------------|--------|
|User Admin         |No      |
|Prism Central Admin|No      |

**Note:** If no role is assigned, the local user will only get `Viewer` permissions


### Required roles: Directory user

Assign following role in the user role-mapping if a non-local user is required: 

|Role               |Required|
|-------------------|--------|
|Viewer             |Yes     |
