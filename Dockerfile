# Use an official lightweight Python image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy and install dependencies
COPY scripts/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the indexer script with an absolute path
COPY scripts/indexer.py /app/scripts/

# Set the entrypoint to run the indexer using an absolute path
ENTRYPOINT ["python", "/app/scripts/indexer.py"]