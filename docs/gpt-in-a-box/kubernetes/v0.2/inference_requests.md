Kubeflow serving can be inferenced and managed through its Inference APIs. Find out more about Kubeflow serving APIs in the official [Inference API](https://kserve.github.io/website/0.8/modelserving/v1beta1/torchserve/#model-inference) documentation.

### Set HOST and PORT  
The first step is to [determine the ingress IP and ports](https://kserve.github.io/website/0.8/get_started/first_isvc/#4-determine-the-ingress-ip-and-ports) and set INGRESS_HOST and INGRESS_PORT.  
The following command assigns the IP address of the host where the Istio Ingress Gateway pod is running to the INGRESS_HOST variable:  
```
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
```  
The following command assigns the node port used for the HTTP2 service of the Istio Ingress Gateway to the INGRESS_PORT variable:
```
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
```

### Set Service Host Name
Next step is to determine service hostname. 
This command retrieves the hostname of a specific InferenceService in a Kubernetes environment by extracting it from the status.url field and assigns it to the SERVICE_HOSTNAME variable:
```
SERVICE_HOSTNAME=$(kubectl get inferenceservice <DEPLOYMENT_NAME> -o jsonpath='{.status.url}' | cut -d "/" -f 3)
```
#### Example:
```
SERVICE_HOSTNAME=$(kubectl get inferenceservice llm-deploy -o jsonpath='{.status.url}' | cut -d "/" -f 3)
```

### Curl request to get inference
In the next step inference can be done on the deployed model.
The following is the template command for inferencing with a json file:
```
curl -v -H "Host: ${SERVICE_HOSTNAME}" -H "Content-Type: application/json" http://${INGRESS_HOST}:${INGRESS_PORT}/v2/models/{model_name}/infer -d @{input_file_path}
```
#### Examples:  
Curl request for MPT-7B model
```
curl -v -H "Host: ${SERVICE_HOSTNAME}" -H "Content-Type: application/json" http://${INGRESS_HOST}:${INGRESS_PORT}/v2/models/mpt_7b/infer -d @$WORK_DIR/data/qa/sample_text1.json
```
Curl request for Falcon-7B model
```
curl -v -H "Host: ${SERVICE_HOSTNAME}" -H "Content-Type: application/json" http://${INGRESS_HOST}:${INGRESS_PORT}/v2/models/falcon_7b/infer -d @$WORK_DIR/data/summarize/sample_text1.json
```
Curl request for Llama2-7B model
```
curl -v -H "Host: ${SERVICE_HOSTNAME}" -H "Content-Type: application/json" http://${INGRESS_HOST}:${INGRESS_PORT}/v2/models/llama2_7b/infer -d @$WORK_DIR/data/translate/sample_text1.json
```

### Input data format
Input data should be in **JSON** format. The input should be a '.json' file containing the prompt in the format below:
```
{
  "id": "42",
  "inputs": [
      {
          "name": "input0",
          "shape": [-1],
          "datatype": "BYTES",
          "data": ["Capital of India?"]
      }
  ]
}
```