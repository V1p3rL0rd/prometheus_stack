#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
sudo yum install -y wget curl tar
sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
sudo yum install -y golang

# Create users and directories
echo "Creating users and directories..."
sudo useradd -r -s /bin/false prometheus
sudo useradd -r -s /bin/false alertmanager
sudo useradd -r -s /bin/false grafana

sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo mkdir -p /etc/alertmanager /var/lib/alertmanager
sudo mkdir -p /etc/grafana /var/lib/grafana

# Install Prometheus
echo "Installing Prometheus..."
PROMETHEUS_VERSION="2.45.0"
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
sudo cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/consoles /etc/prometheus
sudo cp -r prometheus-${PROMETHEUS_VERSION}.linux-amd64/console_libraries /etc/prometheus

# Install Alertmanager
echo "Installing Alertmanager..."
ALERTMANAGER_VERSION="0.25.0"
wget https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz
tar xvf alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz
sudo cp alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager /usr/local/bin/

# Install Grafana
echo "Installing Grafana..."
sudo yum install -y https://dl.grafana.com/oss/release/grafana-10.0.3-1.x86_64.rpm

# Set permissions
echo "Setting permissions..."
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
sudo chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/alertmanager
sudo chown -R grafana:grafana /etc/grafana /var/lib/grafana

# Create systemd services
echo "Creating systemd services..."

# Prometheus service
cat << EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Alertmanager service
cat << EOF | sudo tee /etc/systemd/system/alertmanager.service
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
User=alertmanager
Group=alertmanager
Type=simple
ExecStart=/usr/local/bin/alertmanager \
    --config.file=/etc/alertmanager/alertmanager.yml \
    --storage.path=/var/lib/alertmanager

[Install]
WantedBy=multi-user.target
EOF

# Create base configurations
echo "Creating base configurations..."

# Prometheus config
cat << EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# Alertmanager config
cat << EOF | sudo tee /etc/alertmanager/alertmanager.yml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'email-notifications'

receivers:
- name: 'email-notifications'
  email_configs:
  - to: 'admin@example.com'
    from: 'alertmanager@example.com'
    smarthost: 'smtp.example.com:587'
    auth_username: 'alertmanager'
    auth_password: 'password'
EOF

# Start services
echo "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable prometheus alertmanager grafana-server
sudo systemctl start prometheus alertmanager grafana-server

# Cleanup
echo "Cleaning up temporary files..."
rm -rf prometheus-${PROMETHEUS_VERSION}.linux-amd64*
rm -rf alertmanager-${ALERTMANAGER_VERSION}.linux-amd64*

echo "Installation completed!"
echo "Prometheus is available at http://localhost:9090"
echo "Alertmanager is available at http://localhost:9093"
echo "Grafana is available at http://localhost:3000" 