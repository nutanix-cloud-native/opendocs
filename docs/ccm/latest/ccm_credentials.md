# Credentials

Nutanix CCM requires credentials to connect to Prism Central. These credentials need to be stored in a secret in following format:

```YAML
---
apiVersion: v1
kind: Secret
metadata:
  name: nutanix-creds
  namespace: kube-system
stringData:
  credentials: |
    [
      {
        "type": "basic_auth", 
        "data": { 
          "prismCentral":{
            "username": "$NUTANIX_USERNAME", 
            "password": "$NUTANIX_PASSWORD"
          },
          "prismElements": null
        }
      }
    ]

```

See [Requirements](./requirements.md) for more information on the required permissions.