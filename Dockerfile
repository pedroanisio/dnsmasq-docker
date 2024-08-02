# Use Debian bookworm-slim as the base image
FROM debian:bookworm-slim

# Install necessary packages
RUN apt-get update && \
    apt-get install -y dnsmasq python3 python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /opt/docker/dnsmasq

# Copy Python scripts and configuration files
COPY scripts/requirements.txt /opt/docker/dnsmasq/scripts/requirements.txt
COPY scripts/generate_config.py /opt/docker/dnsmasq/scripts/generate_config.py
COPY config /opt/docker/dnsmasq/config

# Install Python dependencies
RUN pip3 install -r /opt/docker/dnsmasq/scripts/requirements.txt

# Generate configuration files
RUN python3 /opt/docker/dnsmasq/scripts/generate_config.py

# Expose DNS ports
EXPOSE 53/tcp 53/udp

# Run dnsmasq with the generated configuration
CMD ["dnsmasq", "--no-daemon", "--conf-file=/opt/docker/dnsmasq/config/generated/dnsmasq.conf"]
