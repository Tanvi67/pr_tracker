# PR Tracker — Complete DevOps Implementation Guide

This document describes the end-to-end DevOps implementation for **PR Tracker**, integrating **Docker**, **GitHub Actions (CI/CD)**, **Terraform (IaC)**, **Ansible (Configuration Management)**, **AWS EC2**, and **Nagios (Monitoring)**.

---

## 1. DevOps Architecture & Methodology

```mermaid
flowchart TD
    subgraph Developer_Workflow [1. Developer & Version Control]
        DEV[Developer] -->|git push main| GITHUB[GitHub Repository]
    end

    subgraph CI_CD [2. Continuous Integration & Delivery]
        GITHUB -->|Triggers| GHA[GitHub Actions CI/CD Pipeline]
        GHA -->|1. Validate| LINT[Lint & Compose Validate]
        LINT -->|2. Build & Tag| DOCKER_BUILD[Build Microservice Images]
        DOCKER_BUILD -->|Push Images| GHCR[GitHub Container Registry: ghcr.io]
    end

    subgraph Infrastructure_as_Code [3. Infrastructure Provisioning]
        TF[Terraform] -->|Provisions| AWS[AWS Cloud]
        AWS -->|Creates| VPC[VPC & Security Groups\n(Ports 22, 80, 5000, 8080)]
        AWS -->|Launches| EC2[Ubuntu 22.04 LTS EC2 Host]
    end

    subgraph Configuration_Management [4. Server Configuration]
        ANSIBLE[Ansible Playbook] -->|SSH Connection| EC2
        ANSIBLE -->|Installs| DOCKER_ENGINE[Docker & Docker Compose]
        ANSIBLE -->|Configures| NRPE[Nagios NRPE Agent]
        ANSIBLE -->|Deploys Stack| APP_DEPLOY[docker compose up -d]
    end

    subgraph Microservices_Runtime [5. Containerized Services]
        GHCR -->|Pull Latest Images| EC2
        EC2 --> CLIENT[React Client: Port 80]
        EC2 --> ROUTER[Service Router Gateway: Port 5000]
        ROUTER --> MAIN_BACKEND[Main Backend: Port 5002]
        ROUTER --> AI_AGENT[AI Agent: Port 5003]
        ROUTER --> MONGO_SVC[MongoDB Service: Port 5004]
        ROUTER --> AUTH_SVC[Auth Backend: Port 5005]
    end

    subgraph Monitoring_Alerts [6. Centralized Monitoring]
        NAGIOS[Nagios Core: Port 8080]
        NAGIOS -->|Check Ping/CPU/Disk/Load| EC2
        NAGIOS -->|Check HTTP 200| CLIENT
        NAGIOS -->|Check /api/health| ROUTER
        NAGIOS -->|Alert on Failure| EMAIL[Email Notifications]
    end
```

---

## 2. Directory Structure of DevOps Components

```text
pr_tracker/
├── .github/
│   └── workflows/
│       ├── deploy.yml             # Main CI/CD Pipeline (Validate -> Build -> Deploy)
│       └── terraform.yml          # On-demand AWS Infrastructure Provisioning
├── ansible/
│   ├── ansible.cfg                # Ansible defaults & privilege escalation
│   ├── inventory.ini.example      # EC2 target host connection definition
│   └── playbook.yml               # Automated host bootstrapping & container deployment
├── terraform/
│   ├── provider.tf                # AWS provider definition
│   ├── variables.tf               # Region, AMI, instance type, security group vars
│   ├── main.tf                    # AWS EC2, Security Group (22, 80, 5000, 8080)
│   ├── outputs.tf                 # EC2 Public IP, URLs, and SSH command output
│   └── terraform.tfvars.example   # Example variables file
├── nagios/
│   └── conf.d/
│       ├── hosts.cfg              # Monitored host definitions
│       ├── services.cfg           # Service checks (Client 80, Gateway /api/health, CPU, Disk)
│       ├── commands.cfg           # Custom check command definitions
│       └── contacts.cfg           # Alerting contacts & email notifications
├── docker-compose.yml             # Unified production multi-service stack + Nagios
├── docker-compose.monitoring.yml  # Standalone Nagios monitoring compose configuration
└── DEVOPS_GUIDE.md                # This comprehensive execution manual
```

---

## 3. Step-by-Step Implementation & Execution

### Stage 1: Infrastructure Provisioning with Terraform

1. Open a terminal in the `terraform/` directory:
   ```bash
   cd terraform
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Configure your AWS credentials (`AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` via `aws configure` or environment variables).
3. Initialize and provision the AWS infrastructure:
   ```bash
   terraform init
   terraform plan
   terraform apply -auto-approve
   ```
4. Note down the outputs:
   - `public_ip`: EC2 Public IP
   - `ssh_command`: SSH command using your `.pem` key
   - `client_url`: Web interface URL (`http://<EC2_IP>`)
   - `nagios_dashboard_url`: Monitoring UI (`http://<EC2_IP>:8080`)

---

### Stage 2: Server Configuration & Deployment with Ansible

1. Navigate to the `ansible/` directory:
   ```bash
   cd ../ansible
   cp inventory.ini.example inventory.ini
   ```
2. Edit `inventory.ini` and set `ansible_host` to your EC2 public IP.
3. Ensure your SSH private key `pr-tracker.pem` has strict permissions:
   ```bash
   chmod 400 ../pr-tracker.pem
   ```
4. Run the Ansible playbook to install Docker, configure security, and deploy PR Tracker:
   ```bash
   ansible-playbook -i inventory.ini playbook.yml
   ```

---

### Stage 3: CI/CD Automation with GitHub Actions

The repository includes a 3-stage GitHub Actions pipeline configured in `.github/workflows/deploy.yml`:

1. **Stage 1 (Validate)**: Lints client code and validates `docker-compose.yml` syntax.
2. **Stage 2 (Build & Push)**: Builds container images for all 6 microservices in parallel and pushes them to GitHub Container Registry (`ghcr.io/tanvi67/pr-tracker-*`).
3. **Stage 3 (Deploy)**: Connects to the AWS EC2 instance over SSH, pulls the latest images, triggers rolling container recreation, and verifies the `/api/health` endpoint.

#### GitHub Secrets Required:
Configure the following in **GitHub Repository -> Settings -> Secrets and variables -> Actions**:
- `EC2_HOST`: Public IP of your EC2 instance.
- `EC2_USERNAME`: `ubuntu`
- `EC2_PRIVATE_KEY`: Content of your `pr-tracker.pem` file.
- `GHCR_PAT`: GitHub Personal Access Token with `read:packages` and `write:packages` scope (or use default `GITHUB_TOKEN`).
- `VITE_SERVER_ENDPOINT`: `http://<EC2_HOST>:5000`

---

### Stage 4: Operational Monitoring with Nagios

Nagios Core runs containerized on port `8080` (or as host daemon via Ansible) and continuously monitors the application:

1. **Access Nagios Web Dashboard**:
   - URL: `http://<EC2_HOST>:8080`
   - Default Username: `nagiosadmin`
   - Default Password: `admin123`

2. **Configured Service Checks**:
   | Check Name | Target / Port | Expected Result | Thresholds / Frequency |
   |---|---|---|---|
   | **Host Ping** | ICMP | 0% packet loss | Checked every 5 mins |
   | **Root Partition Disk** | `/` mount | Space usage < 80% | Warning: 80%, Critical: 90% |
   | **Current CPU Load** | Host CPU | Load average within limits | Warning: 5.0, Critical: 10.0 |
   | **Total Processes** | Kernel | < 250 processes | Warning: 250, Critical: 400 |
   | **Frontend Web Client** | Port 80 HTTP | HTTP 200 OK | Checked every 2 mins |
   | **API Gateway Health** | Port 5000 `/api/health` | HTTP 200 & `"status":"ok"` | Checked every 2 mins |
   | **Core Backend** | Port 5002 TCP | Port open & listening | Checked every 5 mins |
   | **AI Agent** | Port 5003 TCP | Port open & listening | Checked every 5 mins |
   | **MongoDB Service** | Port 5004 TCP | Port open & listening | Checked every 5 mins |

3. **Simulating a Failure & Testing Alerts**:
   To test Nagios alert detection, stop a service on the EC2 host:
   ```bash
   docker stop pr-tracker-service-router
   ```
   Within 2 minutes, Nagios will flag `API Gateway Service Router Health` as **CRITICAL (Connection refused)** and send an alert notification.

---

## 4. Verification Checklist

- [x] Multi-service container definitions in `docker-compose.yml`
- [x] Docker image build & tag standardization with GHCR
- [x] AWS EC2 & Security Group provisioning via `terraform/`
- [x] Host configuration & Docker installation via `ansible/`
- [x] Automated CI/CD pipeline via `.github/workflows/deploy.yml`
- [x] Nagios monitoring & health checks via `nagios/conf.d/`
