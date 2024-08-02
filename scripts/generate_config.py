import yaml
import jinja2
import os

# Define base directory
BASE_DIR = '/opt/docker/dnsmasq/config'

# Define file paths
yaml_path = os.path.join(BASE_DIR, 'dns_config.yml')
template_path = os.path.join(BASE_DIR, 'dnsmasq.conf.j2')
output_path = os.path.join(BASE_DIR, 'generated/dnsmasq.conf')
hosts_output_dir = os.path.join(BASE_DIR, 'generated/hosts.d')

# Ensure output directories exist
os.makedirs(hosts_output_dir, exist_ok=True)

# Load YAML configuration
with open(yaml_path, 'r') as yaml_file:
    config = yaml.safe_load(yaml_file)

# Load Jinja2 template
with open(template_path, 'r') as template_file:
    template = jinja2.Template(template_file.read())

# Render template with data
rendered_conf = template.render(config)

# Write rendered configuration to file
with open(output_path, 'w') as conf_file:
    conf_file.write(rendered_conf)

# Generate hosts files for each domain
for domain in config['domains']:
    hosts_output_path = os.path.join(hosts_output_dir, f"{domain['name']}.hosts")
    with open(hosts_output_path, 'w') as hosts_file:
        # Handle hosts within subnets
        if 'subnets' in domain:
            for subnet, data in domain['subnets'].items():
                for host in data['hosts']:
                    hostname = host.get('override', host['name'])
                    line = f"{host['ip']} {hostname}.{subnet}.{domain['name']}\n"
                    hosts_file.write(line)
        
        # Handle standalone hosts
        if 'hosts' in domain:
            for host in domain['hosts']:
                hostname = host.get('override', host['name'])
                line = f"{host['ip']} {hostname}.{domain['name']}\n"
                hosts_file.write(line)

print("Configuration files generated successfully.")
