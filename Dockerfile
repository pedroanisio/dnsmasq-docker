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

# Ensure the generated hosts.d directory exists
RUN mkdir -p /etc/hosts.d

# Copy generated host files to the correct location
RUN cp /opt/docker/dnsmasq/config/generated/hosts.d/*.hosts /etc/hosts.d/

# Copy the generated dnsmasq.conf file to the correct location
RUN cp /opt/docker/dnsmasq/config/generated/dnsmasq.conf /etc/dnsmasq.conf

# Expose DNS ports
EXPOSE 53/tcp 53/udp

# Run dnsmasq with the generated configuration
CMD ["dnsmasq", "--no-daemon", "--conf-file=/etc/dnsmasq.conf"]
