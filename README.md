# Monitoring Stack Deployment Scripts

This repository contains scripts for automated deployment of Prometheus, Grafana, and Alertmanager monitoring stack on RHEL and Ubuntu systems.

## Components

- Prometheus 2.45.0
- Alertmanager 0.25.0
- Grafana 10.0.3

## Prerequisites

- Sudo privileges
- Internet connection
- At least 2GB of free RAM
- At least 10GB of free disk space

## Usage

### For RHEL Systems
```bash
chmod +x gap_stack_rhel.sh
sudo ./gap_stack_rhel.sh
```

### For Ubuntu Systems
```bash
chmod +x gap_stack_ubuntu.sh
sudo ./gap_stack_ubuntu.sh
```

## Default Access Points

After installation, the following services will be available:

- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Grafana: http://localhost:3000

## Configuration

### Alertmanager Email Notifications

Before running the script, modify the email configuration in the script:
- Update SMTP server details
- Set your email address
- Configure authentication credentials

### Security Notes

- All services run under dedicated system users
- Services are configured to listen on localhost by default
- Configure firewall rules if external access is needed

## Troubleshooting

1. Check service status:
```bash
sudo systemctl status prometheus
sudo systemctl status alertmanager
sudo systemctl status grafana-server
```

2. View logs:
```bash
sudo journalctl -u prometheus
sudo journalctl -u alertmanager
sudo journalctl -u grafana-server
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
