# Custom Labeling

Enabling the Nutanix CCM custom labeling feature will add additional labels to the Kubernetes nodes. See [Nutanix CCM Configuration](./ccm_configuration.md) for more information on how to configure CCM to enable custom labeling.

The following labels will be added:

|Label                         |Description                                                      |
|------------------------------|-----------------------------------------------------------------|
|nutanix.com/prism-element-uuid|UUID of the Prism Element cluster hosting the Kubernetes node VM.|
|nutanix.com/prism-element-name|Name of the Prism Element cluster hosting the Kubernetes node VM.|
|nutanix.com/prism-host-uuid   |UUID of the Prism AHV host hosting the Kubernetes node VM.       |
|nutanix.com/prism-host-name   |Name of the Prism AHV host hosting the Kubernetes node VM.       |

Nutanix CCM will reconcile the labels periodically. 