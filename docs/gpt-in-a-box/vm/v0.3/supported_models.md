# Supported Models for Virtual Machine Version

GPT-in-a-Box currently supports a curated set of HuggingFace models that are validated and tested. Information pertaining to these models is stored in the ```llm/model_config.json``` file.

The Supported Models are :

| Model Name | HuggingFace Repository ID |
| --- | --- |
| mpt_7b | [mosaicml/mpt_7b](https://huggingface.co/mosaicml/mpt-7b) |
| falcon_7b | [tiiuae/falcon-7b](https://huggingface.co/tiiuae/falcon-7b) |
| llama2_7b | [meta-llama/Llama-2-7b-hf](https://huggingface.co/meta-llama/Llama-2-7b-hf) |
| phi-1_5 | [microsoft/phi-1_5](https://huggingface.co/microsoft/phi-1_5) |
| gpt2 | [gpt2](https://huggingface.co/gpt2) |
| codellama_7b_python | [codellama/CodeLlama-7b-Python-hf](https://huggingface.co/codellama/CodeLlama-7b-Python-hf) |
| llama2_7b_chat | [meta-llama/Llama-2-7b-chat-hf](https://huggingface.co/meta-llama/Llama-2-7b-chat-hf) |

!!! note
    To start the inference server with any HuggingFace model, refer to [**HuggingFace Model Support**](huggingface_model.md) documentation.