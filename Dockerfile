# Dockerfile

# --- Stage 1: The Builder ---
# This stage installs all dependencies, including build-time tools.
FROM python:3.11-slim-bookworm AS builder

LABEL stage="builder"

# Set environment variables for a clean build
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off

# Install build-essential for C extensions (like in tree-sitter)
# and clean up apt cache in the same layer to reduce size.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy only the requirements file to leverage Docker's layer caching.
WORKDIR /app
# CORRECTED PATH: Copy requirements.txt from the scripts directory.
COPY scripts/requirements.txt .

# Install Python dependencies. They are installed into the system's Python site-packages.
RUN pip install -r requirements.txt


# --- Stage 2: The Final Image ---
# This stage is a clean runtime environment. It copies only what's needed
# from the builder stage, resulting in a smaller and more secure final image.
FROM python:3.11-slim-bookworm

# Add metadata labels for maintainability.
LABEL author="Richard Joseph"
LABEL description="Docker image for the Code-Turtle Indexer GitHub Action."

# Set environment variable for Python.
ENV PYTHONUNBUFFERED=1

# Copy the installed Python packages from the builder stage.
# This brings in all the dependencies without the build tools (like gcc).
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the application code into the image.
COPY scripts/ /scripts/

# Set the working directory for the action. /github/workspace is the
# standard location where the repository is checked out.
WORKDIR /github/workspace

# Define the entrypoint for the container. This is the command that will run.
ENTRYPOINT ["python", "/scripts/indexer.py"]