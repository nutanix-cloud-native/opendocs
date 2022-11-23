# Credential Management
Cluster API Provider Nutanix Cloud Infrastructure (CAPX) interacts with Nutanix Prism Central (PC) APIs to manage the required Kubernetes cluster infrastructure resources.

PC credentials are required to authenticate to the PC APIs. CAPX currently supports two mechanisms to supply the required credentials:

- Credentials injected into the CAPX manager deployment
- Workload cluster specific credentials

## Credentials injected into the CAPX manager deployment
By default, credentials will be injected into the CAPX manager deployment when CAPX is initialized. See the [getting started guide](./getting_started.md) for more information on the initialization.

Upon initialization a `nutanix-creds` secret will automatically be created in the `capx-system` namespace. This secret will contain the values supplied via the `NUTANIX_USER` and `NUTANIX_PASSWORD` parameters. 

The `nutanix-creds` secret will be used for workload cluster deployment if no other credential is supplied.

### Example
An example of the automatically created `nutanix-creds` secret can be found below:
```yaml
---
apiVersion: v1
kind: Secret
type: Opaque
metadata:
  name: nutanix-creds
  namespace: capx-system
stringData:
  credentials: |
    [
      {
        "type": "basic_auth", 
        "data": { 
          "prismCentral":{
            "username": "<nutanix-user>",
            "password": "<nutanix-password>"
          },
          "prismElements": null
        }
      }
    ]
```

## Workload cluster specific credentials
Users can override the [credentials injected in CAPX manager deployment](#credentials-injected-into-the-capx-manager-deployment) by supplying a credential specific to a workload cluster. The credentials can be supplied by creating a secret in the same namespace as the `NutanixCluster` namespace. 

The secret can be referenced by adding a `credentialRef` inside the `prismCentral` attribute contained in the `NutanixCluster`. 
The secret will also be deleted when the `NutanixCluster` is deleted.

Note: There is a 1:1 relation between the secret and the `NutanixCluster` object. 

### Example
Create a secret in the namespace of the `NutanixCluster`:

```yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: "<my-secret>"
  namespace: "<nutanixcluster-namespace>"
stringData:
  credentials: |
    [
      {
        "type": "basic_auth", 
        "data": { 
          "prismCentral":{
            "username": "<nutanix-user>",
            "password": "<nutanix-password>"
          },
          "prismElements": null
        }
      }
    ]
```

Add a `prismCentral` and corresponding `credentialRef` to the `NutanixCluster`:

```yaml
apiVersion: infrastructure.cluster.x-k8s.io/v1beta1
kind: NutanixCluster
metadata:
  name: "<nutanixcluster-name>"
  namespace: "<nutanixcluster-namespace>"
spec:
  prismCentral:
    ...
    credentialRef:
      name: "<my-secret>"
      kind: Secret
...
```

See the [NutanixCluster](./types/nutanix_cluster.md) documentation for all supported configuration parameters for the `prismCentral` and `credentialRef` attribute.