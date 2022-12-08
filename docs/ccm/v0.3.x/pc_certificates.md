# Certificate Trust

CCM invokes Prism Central APIs using the HTTPS protocol. CCM has different methods to handle the trust of the Prism Central certificates:

- Enable certificate verification (default)
- Configure an additional trust bundle
- Disable certificate verification

See the respective sections below for more information.

## Enable certificate verification (default)
By default CCM will perform certificate verification when invoking Prism Central API calls. This requires Prism Central to be configured with a publicly trusted certificate authority. 
No additional configuration is required in CCM.

## Configure an additional trust bundle
CCM allows users to configure an additional trust bundle. This will allow CCM to verify certificates that are not issued by a publicy trusted certificate authority. 

To configure an additional trust bundle, see the [Configuring the additional trust bundle](#configuring-the-additional-trust-bundle) section for more information.


### Configuring the additional trust bundle

To configure the additional trust bundle it is required to:

- Create a `ConfigMap` containing the additional trust bundle
- Configure the `prismCentral.additionalTrustBundle` object in the CCM `ConfigMap` called `nutanix-config`.

#### Creating the additional trust bundle ConfigMap

CCM supports two different formats for the `ConfigMap` containing the additional trust bundle. The first one is to add the additional trust bundle as a multi-line string in the `ConfigMap`, the second option is to add the trust bundle in `base64` encoded format. See the examples below.

Multi-line string example:
```YAML
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-ca-bundle
  namespace: ${NAMESPACE}
data:
   ca.crt: |
    -----BEGIN CERTIFICATE-----
    <certificate string>
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    <certificate string>
    -----END CERTIFICATE-----
```

`base64` example:

```YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: user-ca-bundle
  namespace: ${NAMESPACE}
binaryData:
  ca.crt: <base64 string>
```

!!! note
    The `base64` string needs to be added as `binaryData`.


#### Configuring the CCM for an additional trust bundle

When the additional trust bundle `ConfigMap` is created, it needs to be referenced in the `nutanix-config` `ConfigMap`. Add the `prismCentral.additionalTrustBundle` object as shown below. Make sure the correct additional trust bundle `ConfigMap` is referenced.

```JSON
 ...
 "prismCentral": {
   ...
   "additionalTrustBundle": {
     "kind": "ConfigMap",
     "name": "user-ca-bundle"
   }
 },
 ...
```

!!! note
    The default value of `prismCentral.insecure` attribute is `false`. It can be omitted when an additional trust bundle is configured. 
    If `prismCentral.insecure` attribute is set to `true`, all certificate verification will be disabled. 


## Disable certificate verification

!!! note
    Disabling certificate verification is not recommended for production purposes and should only be used for testing.


Certificate verification can be disabled by setting the `prismCentral.insecure` attribute to `true` in the `nutanix-config` `ConfigMap`. Certificate verification will be disabled even if an additional trust bundle is configured and the `prismCentral.insecure` attribute is set to `true`. 

Example of how to disable certificate verification:

```JSON
...
"prismCentral": {
  ...
  "insecure": true
},
...
```