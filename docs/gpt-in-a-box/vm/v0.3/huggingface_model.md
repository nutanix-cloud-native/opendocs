# HuggingFace Model Support
!!! Note
    To start the inference server for the [**Validated Models**](validated_models.md), refer to the [**Deploying Inference Server**](inference_server.md) documentation.

We provide the capability to download model files from any HuggingFace repository and generate a MAR file to start an inference server using it with Torchserve.

To start the Inference Server for any other HuggingFace model, follow the steps below.

## Generate Model Archive File for HuggingFace Models
Run the following command for downloading and generating the Model Archive File (MAR) with the HuggingFace Model files :
```
python3 $WORK_DIR/llm/generate.py [--hf_token <HUGGINGFACE_HUB_TOKEN> --repo_version <REPO_VERSION> --handler <CUSTOM_HANDLER_PATH>] --model_name <HUGGINGFACE_MODEL_NAME> --repo_id <HUGGINGFACE_REPO_ID> --model_path <MODEL_PATH> --mar_output <MAR_EXPORT_PATH>
```
Where the arguments are :

- **model_name**:       Name of HuggingFace model
- **repo_id**:          HuggingFace Repository ID of the model
- **repo_version**:     Commit ID of model's HuggingFace repository, defaults to latest HuggingFace commit ID (optional)
- **model_path**:       Absolute path of model files (should be an empty folder)
- **mar_output**:       Absolute path of export of MAR file (.mar)
- **handler**:          Path to custom handler, defaults to llm/handler.py (optional)
- **hf_token**:         Your HuggingFace token. Needed to download and verify LLAMA(2) models.

### Example
Download model files and generate model archive for codellama/CodeLlama-7b-hf:
```
python3 $WORK_DIR/llm/generate.py --model_name codellama_7b_hf --repo_id codellama/CodeLlama-7b-hf --model_path /models/codellama_7b_hf/model_files --mar_output /models/model_store
```

## Start Inference Server with HuggingFace Model
Run the following command to start TorchServe (Inference Server) and run inference on the provided input for HuggingFace models:
```
bash $WORK_DIR/llm/run.sh -n <HUGGINGFACE_MODEL_NAME> -a <MAR_EXPORT_PATH> [OPTIONAL -d <INPUT_PATH>]
```
Where the arguments are :

- **n**:    Name of HuggingFace model 
- **d**:    Absolute path of input data folder (optional)
- **a**:    Absolute path to the Model Store directory

### Example
To start Inference Server with codellama/CodeLlama-7b-hf:
```
bash $WORK_DIR/llm/run.sh -n codellama_7b_hf -a /models/model_store -d $WORK_DIR/data/summarize
```
