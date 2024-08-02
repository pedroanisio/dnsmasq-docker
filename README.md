# Docker-based DNS Server with `dnsmasq`

This project sets up a DNS server using `dnsmasq` in a Docker container, configured with Jinja2 templating and YAML configuration files. It is designed to be flexible, allowing both static and dynamic DNS entries, with configuration managed within the container itself.

## Features

- **Static DNS Entries**: Define specific domain-to-IP mappings.
- **Dynamic DNS Entries**: Configure DNS dynamically for multiple domains, subnets, and hosts.
- **Reverse DNS Support**: Automatic generation of PTR records for reverse DNS lookups.
- **Self-contained**: Runs the Jinja2 templating and YAML parsing within the Docker container.
- **Configurable**: Easily manage DNS settings using a structured YAML file.
- **Logging**: DNS queries are logged for debugging and monitoring purposes.

## Directory Structure

```plaintext
/opt/docker/dnsmasq/
├── Dockerfile
├── compose
│   └── docker-compose.yml
├── config
│   ├── dns_config.yml         # Main configuration file in YAML
│   ├── dnsmasq.conf.j2        # Jinja2 template for dnsmasq
├── scripts
│   ├── generate_config.py     # Python script for templating
│   └── requirements.txt       # Python requirements file
└── data                       # Log files and persistent data
```

## Getting Started

### Prerequisites

- **Docker**: Ensure Docker is installed on your machine.
- **Docker Compose**: Required for orchestrating the container setup.

### Installation

1. **Clone the Repository**:

   ```bash
   git clone <repository-url>
   cd /opt/docker/dnsmasq
   ```

2. **Build and Start the Docker Container**:

   Navigate to the `compose` directory and run the following command to build and start the container:

   ```bash
   cd compose
   docker compose build
   ```

   This command will build the Docker image and run the `dnsmasq` service in detached mode.

3. **Verify the Setup**:

   Ensure the container is running by executing:

   ```bash
   docker ps
   ```

   You should see a container named `dnsmasq` listed in the output.

4. **Test DNS Resolution**:

   Test forward and reverse DNS resolution using `nslookup`:

   ```bash
   nslookup ns1.hyprv.lab.internal 127.0.0.1
   nslookup 10.0.0.10 127.0.0.1
   nslookup internal.example.com 127.0.0.1
   ```

## Configuration

### YAML Configuration File

The `dns_config.yml` file in the `config` directory defines DNS settings, including static DNS entries and domain configurations. Here's a sample configuration:

```yaml
# DNS Forwarding
dns_servers:
  - 8.8.8.8
  - 8.8.4.4

# Static DNS Entries
static_dns_entries:
  - domain: "internal.example.com"
    ip: "192.168.100.10"
  - domain: "backup.example.com"
    ip: "192.168.100.11"

# Domains configuration
domains:
  - name: lab.internal
    subnets:
      hyprv:
        range: 10.0.0.0/24
        hosts:
          - ip: 10.0.0.10
            name: ns1
          - ip: 10.0.0.20
            name: web
          - ip: 10.0.0.30
            name: db

      ants:
        range: 10.0.33.0/24
        hosts:
          - ip: 10.0.33.10
            name: device1
          - ip: 10.0.33.20
            name: device2
          - ip: 10.0.33.30
            name: device3

  - name: example.com
    # No subnets for this domain, just individual hosts
    hosts:
      - ip: 192.168.1.10
        name: webserver
      - ip: 192.168.1.20
        name: dbserver

  - name: home.network
    # Another domain without subnets, using host overrides
    hosts:
      - ip: 192.168.0.5
        name: printer
      - ip: 192.168.0.10
        name: nas
        override: storage
```

#### Explanation:

- **`dns_servers`**: Specifies the upstream DNS servers to which `dnsmasq` will forward requests that it can't resolve locally.
- **`static_dns_entries`**: Allows you to map specific domain names to IP addresses directly.
- **`domains`**: Supports configuring multiple domains, each with optional subnets and hosts.
  - **`name`**: The domain name for this section.
  - **`subnets`**: Define ranges and associated hosts.
  - **`hosts`**: List of individual host entries, each with an IP and name.
  - **`override`**: Allows you to specify a different hostname if needed.

### Examples

#### Static DNS Entry

To add a static DNS entry for a development server:

```yaml
static_dns_entries:
  - domain: "dev.example.com"
    ip: "192.168.200.10"
```

This maps `dev.example.com` to the IP `192.168.200.10`.

#### Dynamic DNS Entry with Subnets

Adding a new subnet to the `lab.internal` domain:

```yaml
domains:
  - name: lab.internal
    subnets:
      testing:
        range: 10.0.50.0/24
        hosts:
          - ip: 10.0.50.10
            name: test1
          - ip: 10.0.50.20
            name: test2
```

This setup defines a `testing` subnet under `lab.internal` with two hosts.

#### Host Override Example

If you need a host with a different DNS name:

```yaml
  - name: home.network
    hosts:
      - ip: 192.168.0.20
        name: laptop
        override: gamingpc
```

This maps `192.168.0.20` to `gamingpc.home.network` instead of the default `laptop.home.network`.

### Jinja2 Template

The `dnsmasq.conf.j2` file is a Jinja2 template used to generate the `dnsmasq` configuration. It leverages the YAML data to create both forward and reverse DNS entries.

### Python Script

The `generate_config.py` script handles the parsing of YAML and Jinja2 templating to generate the necessary configuration files inside the container.

### Requirements

The `requirements.txt` file specifies Python dependencies for the project:

```plaintext
PyYAML
Jinja2
```

## Running the Jinja2 Template Inside Docker

The Dockerfile is designed to run the Jinja2 templating process inside the Docker container. This makes the setup self-contained and easy to manage.

### Usage

### Adding or Modifying DNS Entries

To add or modify DNS entries, edit the `dns_config.yml` file and rebuild the Docker image using:

```bash
docker-compose up -d --build
```

This will regenerate the configuration files and restart the `dnsmasq` service with updated settings.

### Logging

DNS queries are logged to `/var/log/dnsmasq.log` inside the container. You can access these logs by inspecting the container logs:

```bash
docker logs dnsmasq
```

### Stopping the Service

To stop the `dnsmasq` service, run:

```bash
docker-compose down
```

This command will stop and remove the running container.

## Troubles

hooting

- **DNS Resolution Issues**: Check the YAML configuration and ensure that the domains, IPs, and subnets are correctly defined.
- **Logs**: Inspect the logs for any error messages that might provide insights into issues with the setup.
- **Rebuilding**: Ensure the Docker image is rebuilt after making changes to the configuration files.

## Contributing

Feel free to submit issues and pull requests to contribute to this project. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
