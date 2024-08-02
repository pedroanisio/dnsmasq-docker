# Use Debian bookworm-slim as the base image
FROM debian:bookworm-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y dnsmasq python3 python3-pip python3-venv && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/docker/dnsmasq

# Copy Python scripts and configuration files
COPY scripts/requirements.txt /opt/docker/dnsmasq/scripts/requirements.txt
COPY scripts/generate_config.py /opt/docker/dnsmasq/scripts/generate_config.py
COPY config /opt/docker/dnsmasq/config

# Create a Python virtual environment and install dependencies
RUN python3 -m venv /opt/docker/dnsmasq/venv && \
    /opt/docker/dnsmasq/venv/bin/pip install --upgrade pip && \
    /opt/docker/dnsmasq/venv/bin/pip install -r /opt/docker/dnsmasq/scripts/requirements.txt

# Generate configuration files using the virtual environment
RUN /opt/docker/dnsmasq/venv/bin/python /opt/docker/dnsmasq/scripts/generate_config.py

# Copy generated files to the right location
RUN mkdir -p /etc/hosts.d && \
    cp -r /opt/docker/dnsmasq/config/generated/* /etc/hosts.d/

# Expose DNS ports
EXPOSE 53/tcp 53/udp

# Run dnsmasq with the generated configuration
CMD ["dnsmasq", "--no-daemon", "--conf-file=/etc/hosts.d/dnsmasq.conf"]
