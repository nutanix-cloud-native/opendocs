# Custom Model Support
In some cases you may want to use a custom model, e.g. a custom fine-tuned model. We provide the capability to generate a MAR file with custom model files and start an inference server using it with Torchserve.

## Generate Model Archive File for Custom Models

!!! note
    The model archive files should be placed in a directory accessible by the Nutanix package, e.g. /home/ubuntu/models/&lt;custom_model_name&gt;/model_files. This directory will be passed to the --model_path argument. You'll also need to provide the --mar_output path where you want the model archive export to be stored.

Run the following command for generating the Model Archive File (MAR) with the Custom Model files :
```
python3 $WORK_DIR/llm/generate.py --skip_download [--repo_version <REPO_VERSION> --handler <CUSTOM_HANDLER_PATH>] --model_name <CUSTOM_MODEL_NAME> --model_path <MODEL_PATH> --mar_output <MAR_EXPORT_PATH>
```
Where the arguments are :

- **model_name**:       Name of custom model
- **repo_version**:     Any model version, defaults to "1.0" (optional)
- **model_path**:       Absolute path of custom model files (should be a non empty folder)
- **mar_output**:       Absolute path of export of MAR file (.mar)
- **skip_download**:    Flag to skip downloading the model files, must be set for custom models
- **handler**:          Path to custom handler, defaults to llm/handler.py (optional)

## Start Inference Server with Custom Model Archive File
Run the following command to start TorchServe (Inference Server) and run inference on the provided input for custom models:
```
bash $WORK_DIR/llm/run.sh -n <CUSTOM_MODEL_NAME> -a <MAR_EXPORT_PATH> [OPTIONAL -d <INPUT_PATH>]
```
Where the arguments are :

- **n**:    Name of custom model 
- **d**:    Absolute path of input data folder (optional)
- **a**:    Absolute path to the Model Store directory