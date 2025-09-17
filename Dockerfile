# --- Stage 1: The Builder ---
# This stage installs all dependencies, including build-time tools.
FROM python:3.11-slim-bookworm AS builder

LABEL stage="builder"

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    VIRTUAL_ENV=/opt/venv

# Set up the virtual environment
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install build-essential for C extensions (like in tree-sitter)
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy only the requirements file to leverage Docker's layer caching.
WORKDIR /app
COPY scripts/requirements.txt .

# Install Python dependencies using the updated requirements file
RUN pip install -r requirements.txt


# --- Stage 2: The Final Image ---
# This stage is a clean, secure runtime environment.
FROM python:3.11-slim-bookworm

LABEL author="Richard Joseph" \
      description="Docker image for the Code-Turtle Indexer GitHub Action."

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash appuser

# Copy the virtual env from the builder stage.
COPY --from=builder /opt/venv /opt/venv

# Copy only the application script, and set correct ownership
COPY --chown=appuser:appuser scripts/indexer.py /home/appuser/indexer.py

# --- THIS IS THE FIX ---
# Set environment variables, including redirecting the Hugging Face cache
ENV PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv \
    HF_HOME=/home/appuser/.cache/huggingface
# ----------------------

ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Switch to the non-root user
USER appuser
WORKDIR /github/workspace

# Define the entrypoint for the container.
ENTRYPOINT ["python", "/home/appuser/indexer.py"]