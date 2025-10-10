# Kubernetes Learning Journey 🚀

A complete hands-on guide to learning Kubernetes from scratch, featuring a multi-tier application with full observability stack using Prometheus and Grafana.

## 📋 Table of Contents

- [Overview](#overview)
- [What You'll Learn](#what-youll-learn)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Step-by-Step Guide](#step-by-step-guide)
- [Architecture](#architecture)
- [Monitoring & Observability](#monitoring--observability)
- [Key Concepts Covered](#key-concepts-covered)
- [Useful Commands](#useful-commands)
- [Troubleshooting](#troubleshooting)
- [Next Steps](#next-steps)

## 🎯 Overview

This project demonstrates a complete Kubernetes learning environment with:

- **Infrastructure**: Minikube cluster running locally
- **Multi-tier Application**: Frontend, Backend, and Database
- **Service Communication**: Inter-service networking
- **Configuration Management**: ConfigMaps and Secrets
- **Observability**: Prometheus + Grafana monitoring stack
- **Best Practices**: Resource limits, health checks, and more

## 🎓 What You'll Learn

✅ **Kubernetes Fundamentals**
- Pods, Services, and Deployments
- ConfigMaps and resource management
- Service discovery and networking

✅ **Real-world Application Deployment**
- Multi-tier architecture (Frontend → Backend → Database)
- Service-to-service communication
- Configuration management

✅ **Production-ready Observability**
- Prometheus for metrics collection
- Grafana for visualization and dashboards
- Alertmanager for notifications

✅ **DevOps Best Practices**
- Infrastructure as Code (YAML manifests)
- Scaling and self-healing applications
- Monitoring and alerting

## ⚙️ Prerequisites

### Required Software
- **Docker**: Container runtime
- **kubectl**: Kubernetes CLI
- **Minikube**: Local Kubernetes cluster
- **Helm**: Kubernetes package manager
- **gh CLI**: GitHub CLI (for repository creation)

### Installation (macOS)
```bash
# Install using Homebrew
brew install docker kubectl minikube helm gh

# Verify installations
docker --version
kubectl version --client
minikube version
helm version
gh --version
```

## 🚀 Quick Start

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd kubernetes-learning
   ```

2. **Start Minikube cluster**
   ```bash
   minikube start --driver=docker
   ```

3. **Deploy the application stack**
   ```bash
   # Deploy application components
   kubectl apply -f 08-nginx-configmap.yaml
   kubectl apply -f 05-redis-deployment.yaml
   kubectl apply -f 09-backend-content.yaml
   kubectl apply -f 06-backend-deployment.yaml
   kubectl apply -f 07-frontend-deployment.yaml
   ```

4. **Install monitoring stack**
   ```bash
   # Create monitoring namespace
   kubectl create namespace monitoring
   
   # Add Helm repo and install Prometheus stack
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo update
   helm install prometheus-stack prometheus-community/kube-prometheus-stack \
     --namespace monitoring \
     --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
   ```

5. **Access the applications**
   ```bash
   # Frontend application
   kubectl port-forward service/frontend-service 8081:80
   # Visit: http://localhost:8081
   
   # Grafana dashboard
   kubectl --namespace monitoring port-forward service/prometheus-stack-grafana 3000:80
   # Visit: http://localhost:3000
   # Username: admin, Password: prom-operator
   ```

## 📁 Project Structure

```
kubernetes-learning/
├── README.md                      # This file
├── 01-basic-pod.yaml             # Basic Pod example
├── 02-nginx-service.yaml         # Service example
├── 03-nginx-deployment.yaml      # Deployment example
├── 04-deployment-service.yaml    # Service for deployment
├── 05-redis-deployment.yaml      # Redis database
├── 06-backend-deployment.yaml    # Backend API service
├── 07-frontend-deployment.yaml   # Frontend web service
├── 08-nginx-configmap.yaml       # Nginx configuration
└── 09-backend-content.yaml       # Backend content configuration
```

## 📖 Step-by-Step Guide

### 1. Basic Kubernetes Concepts

Start with understanding the fundamental building blocks:

**Pod** - The smallest deployable unit
```bash
kubectl apply -f 01-basic-pod.yaml
kubectl get pods
```

**Service** - Network endpoint for pods
```bash
kubectl apply -f 02-nginx-service.yaml
kubectl get services
```

**Deployment** - Manages multiple pod replicas
```bash
kubectl apply -f 03-nginx-deployment.yaml
kubectl get deployments
```

### 2. Multi-tier Application

Build a realistic application with multiple components:

1. **Database Layer**: Redis for caching
2. **Backend Layer**: API service
3. **Frontend Layer**: Web server with proxy

### 3. Configuration Management

Learn to externalize configuration:
- **ConfigMaps**: Non-sensitive configuration
- **Environment Variables**: Runtime configuration
- **Volume Mounts**: File-based configuration

### 4. Observability Stack

Set up production-ready monitoring:
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **Alertmanager**: Alert routing and management

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                   │
│  ┌─────────────────────────────────────────────────────┐ │
│  │              Application Namespace                   │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌──────────┐ │ │
│  │  │  Frontend   │    │   Backend   │    │  Redis   │ │ │
│  │  │   (Nginx)   │───▶│    (API)    │───▶│   (DB)   │ │ │
│  │  │   Port 80   │    │   Port 80   │    │ Port 6379│ │ │
│  │  └─────────────┘    └─────────────┘    └──────────┘ │ │
│  └─────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────┐ │
│  │             Monitoring Namespace                     │ │
│  │  ┌─────────────┐    ┌─────────────┐    ┌──────────┐ │ │
│  │  │ Prometheus  │    │   Grafana   │    │Alertmgr  │ │ │
│  │  │  (Metrics)  │───▶│(Dashboard)  │    │(Alerts)  │ │ │
│  │  │  Port 9090  │    │  Port 3000  │    │Port 9093 │ │ │
│  │  └─────────────┘    └─────────────┘    └──────────┘ │ │
│  └─────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

## 📊 Monitoring & Observability

### Grafana Dashboards

Access Grafana at `http://localhost:3000` with:
- **Username**: `admin`
- **Password**: `prom-operator`

**Pre-built Dashboards Available:**
- Kubernetes Cluster Overview
- Node Metrics
- Pod Resources
- Application Performance

### Key Metrics to Monitor

- **Cluster Health**: Node status, pod count
- **Resource Usage**: CPU, Memory, Storage
- **Application Metrics**: Request rate, response time
- **Network**: Traffic patterns, latency

### Sample Prometheus Queries

```promql
# CPU usage across all containers
rate(container_cpu_usage_seconds_total[5m])

# Memory usage by pod
container_memory_usage_bytes

# Pod restart count
kube_pod_container_status_restarts_total

# Service uptime
up
```

## 🧠 Key Concepts Covered

### Kubernetes Resources
- **Pods**: Container execution environment
- **Deployments**: Replica management and rolling updates
- **Services**: Network access and load balancing
- **ConfigMaps**: Configuration data management
- **Namespaces**: Resource organization and isolation

### Operations
- **Scaling**: Horizontal pod scaling
- **Self-healing**: Automatic pod replacement
- **Service Discovery**: DNS-based service location
- **Rolling Updates**: Zero-downtime deployments

### Best Practices
- **Resource Limits**: CPU and memory constraints
- **Health Checks**: Liveness and readiness probes
- **Configuration Externalization**: Environment-specific configs
- **Monitoring**: Observability and alerting

## 🛠️ Useful Commands

### Cluster Management
```bash
# Cluster info
kubectl cluster-info
kubectl get nodes

# View all resources
kubectl get all
kubectl get all --all-namespaces
```

### Pod Operations
```bash
# Get pods
kubectl get pods
kubectl get pods -n monitoring

# Describe pod
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/bash
```

### Service Management
```bash
# List services
kubectl get services
kubectl get svc

# Port forwarding
kubectl port-forward service/<service-name> <local-port>:<service-port>

# Service endpoints
kubectl get endpoints
```

### Scaling and Updates
```bash
# Scale deployment
kubectl scale deployment <deployment-name> --replicas=5

# Rolling update
kubectl set image deployment/<deployment-name> <container-name>=<new-image>

# Rollback
kubectl rollout undo deployment/<deployment-name>
```

### Configuration
```bash
# ConfigMaps
kubectl get configmaps
kubectl describe configmap <configmap-name>

# Apply configurations
kubectl apply -f <file.yaml>
kubectl apply -f <directory>/
```

## 🔧 Troubleshooting

### Common Issues

**Pod stuck in Pending state:**
```bash
kubectl describe pod <pod-name>
# Check Events section for resource constraints
```

**Service not accessible:**
```bash
kubectl get endpoints <service-name>
# Verify pod labels match service selector
```

**Application crashes:**
```bash
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous container logs
```

### Resource Issues
```bash
# Check resource usage
kubectl top nodes
kubectl top pods

# Describe node resources
kubectl describe node minikube
```

## 🚀 Next Steps

Ready to learn more? Explore these advanced topics:

### 1. **Ingress Controllers**
- External load balancing
- SSL termination
- Path-based routing

### 2. **Persistent Storage**
- PersistentVolumes
- PersistentVolumeClaims
- Storage classes

### 3. **Security**
- RBAC (Role-Based Access Control)
- Network Policies
- Pod Security Standards

### 4. **Advanced Deployments**
- StatefulSets
- DaemonSets
- Jobs and CronJobs

### 5. **Automation**
- Horizontal Pod Autoscaler
- Vertical Pod Autoscaler
- Custom Resource Definitions (CRDs)

### 6. **Production Readiness**
- Multi-cluster management
- Backup and disaster recovery
- CI/CD integration

## 🤝 Contributing

Feel free to contribute to this learning resource:

1. Fork the repository
2. Create a feature branch
3. Add your improvements
4. Submit a pull request

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Kubernetes community for excellent documentation
- Prometheus and Grafana teams for observability tools
- Minikube project for local development environment

---

**Happy Learning!** 🎉

Remember: The best way to learn Kubernetes is by doing. Experiment with the configurations, break things, and fix them. That's how you truly understand the platform.