#!/bin/bash

#### Hugging Face TOKEN
#export MY_HF_TOKEN=hf_xxxxxxxxxxxxxxxxxxxx
#### OVHcloud AI ACCESS TOKEN
#export MY_OVHAI_ACCESS_TOKEN=XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

#ovhai app run \
/Users/dletizia/bin/ovhai app run \
    --name techlab-ai-vllm-mistral-small \
    --default-http-port 8000 \
    --label techlab/vllm=mistral \
    --label techlab/ai_deploy_token=_techlab_my_operator_token \
    --gpu 2 \
    --flavor l40s-1-gpu \
    -e OUTLINES_CACHE_DIR=/tmp/.outlines \
    -e HF_TOKEN=$MY_HF_TOKEN \
    -e HF_HOME=/hub \
    -e HF_DATASETS_TRUST_REMOTE_CODE=1 \
    -e HF_HUB_ENABLE_HF_TRANSFER=0 \
    -v standalone:/hub:rw \
    -v standalone:/workspace:rw \
    vllm/vllm-openai:latest \
    -- bash -c "python3 -m vllm.entrypoints.openai.api_server \
        --model mistralai/Mistral-Small-24B-Instruct-2501 \
        --tensor-parallel-size 2 \
        --tokenizer_mode mistral \
        --load_format mistral \
        --config_format mistral \
        --dtype half"
