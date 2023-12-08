# Inference Requests
The Inference Server can be inferenced through the TorchServe Inference API. Find out more about it in the official [TorchServe Inference API](https://pytorch.org/serve/inference_api.html) documentation.

**Server Configuration**

| Variable | Value |
| --- | --- |
| inference_server_endpoint | localhost |
| inference_port | 8080 |

The following are example cURL commands to send inference requests to the Inference Server.

## Ping Request
To find out the status of a TorchServe server, you can use the ping API that TorchServe supports:
```
curl http://{inference_server_endpoint}:{inference_port}/ping
```
### Example
```
curl http://localhost:8080/ping
```
!!! note
    This only provides information on whether the TorchServe server is running. To check whether a model is successfully registered, use the "List Registered Models" request in the [Management Requests](management_requests.md#list-registered-models) documentation.

## Inference Requests
The following is the template command for inferencing with a text file:
```
curl -v -H "Content-Type: application/text" http://{inference_server_endpoint}:{inference_port}/predictions/{model_name} -d @path/to/data.txt
```

The following is the template command for inferencing with a json file:
```
curl -v -H "Content-Type: application/json" http://{inference_server_endpoint}:{inference_port}/predictions/{model_name} -d @path/to/data.json
```

Input data files can be found in the `$WORK_DIR/data` folder.

### Examples 

For MPT-7B model
```
curl -v -H "Content-Type: application/text" http://localhost:8080/predictions/mpt_7b -d @$WORK_DIR/data/qa/sample_text1.txt
```
```
curl -v -H "Content-Type: application/json" http://localhost:8080/predictions/mpt_7b -d @$WORK_DIR/data/qa/sample_text4.json
```

For Falcon-7B model
```
curl -v -H "Content-Type: application/text" http://localhost:8080/predictions/falcon_7b -d @$WORK_DIR/data/summarize/sample_text1.txt
```
```
curl -v -H "Content-Type: application/json" http://localhost:8080/predictions/falcon_7b -d @$WORK_DIR/data/summarize/sample_text3.json
```

For Llama2-7B model
```
curl -v -H "Content-Type: application/text" http://localhost:8080/predictions/llama2_7b -d @$WORK_DIR/data/translate/sample_text1.txt
```
```
curl -v -H "Content-Type: application/json" http://localhost:8080/predictions/llama2_7b -d @$WORK_DIR/data/translate/sample_text3.json
```

### Input data format
Input data can be in either **text** or **JSON** format.

1. For text format, the input should be a '.txt' file containing the prompt

2. For JSON format, the input should be a '.json' file containing the prompt in the format below:
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