# HuggingFace Model Support
!!! Note
    To start the inference server for the [**Validated Models**](validated_models.md), refer to the [**Deploying Inference Server**](inference_server.md) documentation.

We provide the capability to download model files from any HuggingFace repository and generate a MAR file to start an inference server using Kubeflow serving.<br />

To start the Inference Server for any other HuggingFace model, follow the steps below.

## Generate Model Archive File for HuggingFace Models
Run the following command for downloading and generating the Model Archive File (MAR) with the HuggingFace Model files :
```
python3 $WORK_DIR/llm/generate.py [--hf_token <HUGGINGFACE_HUB_TOKEN> --repo_version <REPO_VERSION> --handler <CUSTOM_HANDLER_PATH>] --model_name <HUGGINGFACE_MODEL_NAME> --repo_id <HUGGINGFACE_REPO_ID> --model_path <MODEL_PATH> --output <NFS_LOCAL_MOUNT_LOCATION>
```

* **model_name**:       Name of HuggingFace model
* **repo_id**:          HuggingFace Repository ID of the model
* **repo_version**:     Commit ID of model's HuggingFace repository, defaults to latest HuggingFace commit ID (optional)
* **model_path**:       Absolute path of custom model files (should be empty)
* **output**:           Mount path to your nfs server to be used in the kube PV where config.properties and model archive file be stored
* **handler**:          Path to custom handler, defaults to llm/handler.py (optional)<br />
* **hf_token**:         Your HuggingFace token. Needed to download and verify LLAMA(2) models.

### Example
Download model files and generate model archive for codellama/CodeLlama-7b-hf:
```
python3 $WORK_DIR/llm/generate.py --model_name codellama_7b_hf --repo_id codellama/CodeLlama-7b-hf --model_path /models/codellama_7b_hf/model_files --output /mnt/llm
```

## Start Inference Server with HuggingFace Model Archive File
Run the following command for starting Kubeflow serving and running inference on the given input with a custom MAR file:
```
bash $WORK_DIR/llm/run.sh -n <HUGGINGFACE_MODEL_NAME> -g <NUM_GPUS> -f <NFS_ADDRESS_WITH_SHARE_PATH> -m <NFS_LOCAL_MOUNT_LOCATION> -e <KUBE_DEPLOYMENT_NAME> [OPTIONAL -d <INPUT_PATH>]
```

* **n**:    Name of HuggingFace model
* **d**:    Absolute path of input data folder (Optional)
* **g**:    Number of gpus to be used to execute (Set 0 to use cpu)
* **f**:    NFS server address with share path information
* **m**:    Mount path to your nfs server to be used in the kube PV where model files and model archive file be stored
* **e**:    Name of the deployment metadata

### Example
To start Inference Server with codellama/CodeLlama-7b-hf:
```
bash $WORK_DIR/llm/run.sh -n codellama_7b_hf -d data/qa -g 1 -e llm-deploy -f '1.1.1.1:/llm' -m /mnt/llm
```
