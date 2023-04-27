# Custom Cloud Native role

Cloud Native solutions can be deployed on the Nutanix Cloud Platform with a user with administrative permissions. In various scenarios this is not desired and least privileged user needs to be used to deploy these solutions.

This page will illustrate the steps required to create a custom Cloud Native role in Prism Central that can be assigned to Prism Central users. The custom role will be created using `Ansible` and the [Nutanix Ansible Collection](https://github.com/nutanix/nutanix.ansible){target=_blank}. 

## Prerequisites
- [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html){target=_blank}
- Install the Nutanix `nutanix.ncp` [collection](https://docs.ansible.com/ansible/latest/collections_guide/collections_installing.html#installing-collections-with-ansible-galaxy){target=_blank}

## Steps

- (Optional) Export environment variables to authenticate to Prism Central.
  ```bash
  export NUTANIX_HOST=<Prism Central FQDN/IP>
  export NUTANIX_USERNAME=<Prism Central Username>
  export NUTANIX_PASSWORD=<Prism Central Password>
  ```
  Ensure the user has the required permissions to create a role in Prism Central. 
!!! note
    These variables can also be specified directly in the Ansible Playbook. See the Nutanix Ansible documentation for more details.

- Create a new Ansible playbook YAML file (for example `role.yaml`) that uses the `ntnx_roles` module. See the [example](#example)
- Invoked the playbook: `ansible-playbook role.yaml`
- When the role is created, go to Prism Central and assign users. 


## Example

!!! note 
    Update the `role_name` variable if a different name for the custom role is desired

```YAML
---
- hosts: localhost
  collections:
    - nutanix.ncp
  vars:
    role_name: "Cloud Native Role"
  tasks:
    - name: Create Cloud Native role
      ntnx_roles:
        state: present
        name: "{{ role_name }}"
        permissions:
          - name: "Create_Category_Mapping"
          - name: "Create_Image"
          - name: "Create_Or_Update_Name_Category"
          - name: "Create_Or_Update_Value_Category"
          - name: "Create_Virtual_Machine"
          - name: "Delete_Category_Mapping"
          - name: "Delete_Image"
          - name: "Delete_Name_Category"
          - name: "Delete_Value_Category"
          - name: "Delete_Virtual_Machine"
          - name: "Update_Category_Mapping"
          - name: "Update_Virtual_Machine_Project"
          - name: "Update_Virtual_Machine"
          - name: "View_Category_Mapping"
          - name: "View_Cluster"
          - name: "View_Image"
          - name: "View_Name_Category"
          - name: "View_Project"
          - name: "View_Subnet"
          - name: "View_Value_Category"
          - name: "View_Virtual_Machine"
        wait: true
```
!!! note 
    Verify the documentation of the cloud native solution on the required list of permissions.