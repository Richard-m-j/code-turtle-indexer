# --- Stage 1: The Builder ---
# This stage installs all dependencies in a contained environment.
FROM python:3.11-slim-bookworm AS builder

LABEL stage="builder"

# Set environment variables for a clean build and to use a virtual env
ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=off \
    VIRTUAL_ENV=/opt/venv

# Set up the virtual environment
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install build-essential for C extensions (like in tree-sitter)
# and clean up apt cache in the same layer to reduce size.
RUN apt-get update \
    && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy only the requirements file to leverage Docker's layer caching.
WORKDIR /app
COPY scripts/requirements.txt .

# Install Python dependencies into the virtual environment
RUN pip install -r requirements.txt


# --- Stage 2: The Final Image ---
# This stage is a clean, secure runtime environment.
FROM python:3.11-slim-bookworm

LABEL author="Richard Joseph" \
      description="Docker image for the Code-Turtle Indexer GitHub Action."

ENV PYTHONUNBUFFERED=1 \
    VIRTUAL_ENV=/opt/venv

# Copy the virtual env from the builder stage.
# This brings in all dependencies without build tools like gcc.
COPY --from=builder $VIRTUAL_ENV $VIRTUAL_ENV

# Make the virtual env's python the default
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Create a non-root user for security
RUN useradd --create-home --shell /bin/bash appuser
USER appuser

# Copy the application code into the image.
WORKDIR /home/appuser/app
COPY scripts/ ./scripts/

# Set the working directory for the action, where the repo is checked out.
WORKDIR /github/workspace

# Define the entrypoint for the container.
ENTRYPOINT ["python", "/home/appuser/app/scripts/indexer.py"]