FROM nvidia/cuda:12.1.1-devel-ubuntu22.04

# Install system dependencies
RUN apt-get update && \
    apt-get install -y python3.9 python3-pip curl && \
    ln -s /usr/bin/python3.9 /usr/bin/python && \
    python3 -m pip install --upgrade pip virtualenv && \
    python3 -m virtualenv /opt/venv

ENV PATH="/opt/venv/bin:$PATH"

RUN pip install torch==2.4.0 torchvision==0.19.0 torchaudio==2.4.0 --index-url https://download.pytorch.org/whl/cu124

# Copy entire project structure first
WORKDIR /app
COPY . .

# Install verl as editable package
RUN pip install -e .  # Requires setup.py in project root

RUN pip install -r requirements.txt && \
    pip install flash-attn --no-build-isolation && \
    pip install wandb IPython matplotlib

