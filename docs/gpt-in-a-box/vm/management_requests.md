# Management Requests
The Inference Server can be managed through the TorchServe Management API. Find out more about it in the official [TorchServe Management API](https://pytorch.org/serve/management_api.html) documentation

**Server Configuration**

| Variable | Value |
| --- | --- |
| inference_server_endpoint | localhost |
| management_port | 8081 |

The following are example cURL commands to Manage the Inference Server.

## Describe Registered Model
Once a model is loaded on the Inference Server, we can use the following request to describe the model and it's configuration.

The following is the template command for the same:
```
curl http://{inference_server_endpoint}:{management_port}/models/{model_name}
```

### Examples 
For MPT-7B model
```
curl http://localhost:8081/models/mpt_7b
```
For Falcon-7B model
```
curl http://localhost:8081/models/falcon_7b
```
For Llama2-7B model
```
curl http://localhost:8081/models/llama2_7b
```

## Register Additional Models
TorchServe allows the registering (loading) of multiple models simultaneously. To register multiple models, make sure that the Model Archive Files for the concerned models are stored in the same directory.

The following is the template command for the same:
```
curl -X POST "http://{inference_server_endpoint}:{management_port}/models?url={model_archive_file_name}.mar&initial_workers=1&synchronous=true"
```

### Examples 
For MPT-7B model
```
curl -X POST "http://localhost:8081/models?url=mpt_7b.mar&initial_workers=1&synchronous=true"
```
For Falcon-7B model
```
curl -X POST "http://localhost:8081/models?url=falcon_7b.mar&initial_workers=1&synchronous=true"
```
For Llama2-7B model
```
curl -X POST "http://localhost:8081/models?url=llama2_7b.mar&initial_workers=1&synchronous=true"
```
!!! note
    Make sure the Model Archive file name given in the cURL request is correct and is present in the model store directory.

## Edit Registered Model Configuration
The model can be configured after registration using the Management API of TorchServe. 

The following is the template command for the same:
```
curl -v -X PUT "http://{inference_server_endpoint}:{management_port}/models/{model_name}?min_workers={number}&max_workers={number}&batch_size={number}&max_batch_delay={delay_in_ms}"
```

### Examples 
For MPT-7B model
```
curl -v -X PUT "http://localhost:8081/models/mpt_7b?min_worker=2&max_worker=2"
```
For Falcon-7B model
```
curl -v -X PUT "http://localhost:8081/models/falcon_7b?min_worker=2&max_worker=2"
```
For Llama2-7B model
```
curl -v -X PUT "http://localhost:8081/models/llama2_7b?min_worker=2&max_worker=2"
```
!!! note
    Make sure to have enough GPU and System Memory before increasing number of workers, else the additional workers will fail to load.

## Unregister a Model
The following is the template command to unregister a model from the Inference Server:
```
curl -X DELETE "http://{inference_server_endpoint}:{management_port}/models/{model_name}/{repo_version}"
```
