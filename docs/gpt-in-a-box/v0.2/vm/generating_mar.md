# Generate PyTorch Model Archive File
We will download the model files and generate a Model Archive file for the desired LLM, which will be used by TorchServe to load the model. Find out more about Torch Model Archiver [here](https://github.com/pytorch/serve/blob/master/model-archiver/README.md).

Make two new directories, one to store the model files (model_path) and another to store the Model Archive files (mar_output).

!!! note
    The model store directory (i.e, mar_output) can be the same for multiple Model Archive files. But model files directory (i.e, model_path) should be empty if you're downloading the model.

Run the following command for downloading model files and generating the Model Archive File (MAR) of the desired LLM: 
```
python3 $WORK_DIR/llm/download.py [--no_download --repo_version <REPO_VERSION>] --model_name <MODEL_NAME> --model_path <MODEL_PATH> --mar_output <MAR_EXPORT_PATH> --hf_token <Your_HuggingFace_Hub_Token>
```
Where the arguments are : 

- **model_name**:      Name of model
- **repo_version**:    Commit ID of model's HuggingFace repository (optional, if not provided default set in model_config will be used)
- **model_path**:      Absolute path of model files (should be empty if downloading)
- **mar_output**:      Absolute path of export of MAR file (.mar)
- **no_download**:     Flag to skip downloading the model files
- **hf_token**:        Your HuggingFace token. Needed to download and verify LLAMA(2) models.

The available LLMs are mpt_7b (mosaicml/mpt_7b), falcon_7b (tiiuae/falcon-7b), llama2_7b (meta-llama/Llama-2-7b-hf).

## Examples
The following are example commands to generate the model archive file.

Download MPT-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/download.py --model_name mpt_7b --model_path /home/ubuntu/models/mpt_7b/model_files --mar_output /home/ubuntu/models/model_store
```
Download Falcon-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/download.py --model_name falcon_7b --model_path /home/ubuntu/models/falcon_7b/model_files --mar_output /home/ubuntu/models/model_store
```
Download Llama2-7B model files and generate model archive for it:
```
python3 $WORK_DIR/llm/download.py --model_name llama2_7b --model_path /home/ubuntu/models/llama2_7b/model_files --mar_output /home/ubuntu/models/model_store --hf_token <Your_HuggingFace_Hub_Token>
```