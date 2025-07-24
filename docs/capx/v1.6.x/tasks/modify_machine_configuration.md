# Modifying Machine Configurations

Since all attributes of the `NutanixMachineTemplate` resources are immutable, follow the [Updating Infrastructure Machine Templates](https://cluster-api.sigs.k8s.io/tasks/updating-machine-templates.html?highlight=machine%20template#updating-infrastructure-machine-templates){target=_blank} procedure to modify the configuration of machines in an existing CAPX cluster.
See the [NutanixMachineTemplate](../types/nutanix_machine_template.md) documentation for all supported configuration parameters.

!!! note
    Manually modifying existing and linked `NutanixMachineTemplate` resources will not trigger a rolling update of the machines. 

!!! note
    Do not modify the virtual machine configuration of CAPX cluster nodes manually in Prism/Prism Central. 
    CAPX will not automatically revert the configuration change but performing scale-up/scale-down/upgrade operations will override manual modifications. Only use the `Updating Infrastructure Machine` procedure referenced above to perform configuration changes.