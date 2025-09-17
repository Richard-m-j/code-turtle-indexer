# --- Builder Stage ---
# Use the slim image as a base to build our dependencies
FROM python:3.10-slim as builder

# Set the working directory
WORKDIR /app

# Install build dependencies that might be needed for some python packages
RUN apt-get update && apt-get install -y --no-install-recommends build-essential

# Copy and install Python dependencies
COPY scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# --- Final Stage ---
# Use a distroless image which contains only python and its dependencies
FROM gcr.io/distroless/python3-debian11

# Set the working directory
WORKDIR /app

# Copy the installed Python packages from the builder stage
COPY --from=builder /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the application script
COPY scripts/indexer.py /app/scripts/

# Set the entrypoint to run the indexer
ENTRYPOINT ["/usr/local/bin/python", "/app/scripts/indexer.py"]