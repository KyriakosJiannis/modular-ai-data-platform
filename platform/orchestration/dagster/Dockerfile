FROM python:3.11-slim

# Folder for Dagster code
WORKDIR /opt/dagster/app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Dagster definitions
COPY definitions.py .
COPY workspace.yaml .

# Dagster runtime storage
ENV DAGSTER_HOME=/dagster_home

# Create dagster home directory
RUN mkdir -p /dagster_home

# Default command (can be overridden by docker-compose)
CMD ["dagster-webserver", "-h", "0.0.0.0", "-p", "3050", "-w", "/opt/dagster/app/workspace.yaml"]
