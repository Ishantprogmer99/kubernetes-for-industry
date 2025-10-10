# 📚 Kubernetes Learning Revision Guide

**A Complete Deep-Dive Study Guide for Kubernetes Concepts**  
*Based on the kubernetes-learning project implementations*

---

## 🎯 Table of Contents

1. [Core Kubernetes Concepts](#-core-kubernetes-concepts)
2. [Resource Analysis & Learning Path](#-resource-analysis--learning-path)
3. [Hands-on Examples Walkthrough](#-hands-on-examples-walkthrough)
4. [Architecture Deep Dive](#-architecture-deep-dive)
5. [Configuration Management Patterns](#-configuration-management-patterns)
6. [Service Communication & Networking](#-service-communication--networking)
7. [Resource Management & Best Practices](#-resource-management--best-practices)
8. [Monitoring & Observability](#-monitoring--observability)
9. [Troubleshooting Scenarios](#-troubleshooting-scenarios)
10. [Advanced Concepts & Next Steps](#-advanced-concepts--next-steps)
11. [Practical Commands Reference](#-practical-commands-reference)
12. [Interview Preparation](#-interview-preparation)

---

## 🧠 Core Kubernetes Concepts

### 1. Pod - The Fundamental Unit

**What is a Pod?**
- Smallest deployable unit in Kubernetes
- Contains one or more tightly coupled containers
- Containers in a pod share network and storage
- Each pod gets a unique IP address

**Example Analysis: `01-basic-pod.yaml`**
```yaml
apiVersion: v1           # API version for core resources
kind: Pod                # Resource type
metadata:
  name: nginx-pod        # Unique identifier within namespace
  labels:
    app: nginx           # Key-value pairs for selection
spec:
  containers:
  - name: nginx          # Container name within pod
    image: nginx:1.21    # Docker image to run
    ports:
    - containerPort: 80  # Port exposed by container
```

**Key Learning Points:**
- Pods are ephemeral (temporary)
- Pod IP addresses change when recreated
- Direct pod creation is rare in production
- Labels are crucial for service discovery

### 2. Service - Network Abstraction

**What is a Service?**
- Provides stable network endpoint for pods
- Load balances traffic across multiple pods
- Uses labels to select target pods
- Different types: ClusterIP, NodePort, LoadBalancer

**Example Analysis: `02-nginx-service.yaml`**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
spec:
  selector:
    app: nginx          # Matches pods with this label
  ports:
  - protocol: TCP
    port: 80           # Service port (cluster-internal)
    targetPort: 80     # Pod port to forward to
  type: ClusterIP      # Internal cluster access only
```

**Service Types Explained:**
- **ClusterIP**: Internal cluster communication only
- **NodePort**: Exposes service on each node's IP
- **LoadBalancer**: Cloud provider load balancer
- **ExternalName**: DNS CNAME record mapping

### 3. Deployment - Managing Pod Replicas

**What is a Deployment?**
- Manages ReplicaSets and Pods
- Provides declarative updates
- Supports rolling updates and rollbacks
- Ensures desired number of replicas

**Example Analysis: `03-nginx-deployment.yaml`**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3                    # Desired number of pods
  selector:
    matchLabels:
      app: nginx-app             # Pods to manage
  template:                      # Pod template
    metadata:
      labels:
        app: nginx-app           # Labels for created pods
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        resources:
          requests:              # Minimum resources needed
            memory: "64Mi"
            cpu: "250m"
          limits:                # Maximum resources allowed
            memory: "128Mi"
            cpu: "500m"
```

**Deployment Benefits:**
- Self-healing: Replaces failed pods
- Scaling: Easy horizontal scaling
- Updates: Rolling updates with zero downtime
- Rollback: Can revert to previous versions

---

## 📊 Resource Analysis & Learning Path

### Learning Progression Map

```
Basic Concepts → Multi-tier App → Configuration → Monitoring
     ↓               ↓              ↓             ↓
1. Pod           5. Redis       8. ConfigMaps   Prometheus
2. Service       6. Backend     9. Volumes      Grafana
3. Deployment    7. Frontend    Environment     Alerting
4. Scaling                      Variables
```

### File-by-File Learning Analysis

| File | Concept | Complexity | Key Learning |
|------|---------|------------|--------------|
| `01-basic-pod.yaml` | Pod | ⭐ Basic | Container orchestration basics |
| `02-nginx-service.yaml` | Service | ⭐ Basic | Network abstraction |
| `03-nginx-deployment.yaml` | Deployment | ⭐⭐ Intermediate | Replica management |
| `04-deployment-service.yaml` | Service+Deploy | ⭐⭐ Intermediate | Service-deployment binding |
| `05-redis-deployment.yaml` | Database | ⭐⭐ Intermediate | Stateful service patterns |
| `06-backend-deployment.yaml` | Backend API | ⭐⭐⭐ Advanced | Multi-container concepts |
| `07-frontend-deployment.yaml` | Frontend | ⭐⭐⭐ Advanced | Reverse proxy patterns |
| `08-nginx-configmap.yaml` | ConfigMap | ⭐⭐⭐ Advanced | Configuration management |
| `09-backend-content.yaml` | Content Config | ⭐⭐ Intermediate | Dynamic content loading |

---

## 🔍 Hands-on Examples Walkthrough

### Example 1: Basic Pod Creation

**Command Sequence:**
```bash
# 1. Create pod
kubectl apply -f 01-basic-pod.yaml

# 2. Verify creation
kubectl get pods

# 3. Describe pod details
kubectl describe pod nginx-pod

# 4. Access pod directly (for testing)
kubectl port-forward pod/nginx-pod 8080:80

# 5. Check logs
kubectl logs nginx-pod

# 6. Execute commands inside pod
kubectl exec -it nginx-pod -- /bin/bash
```

**What Happens:**
1. Kubernetes pulls nginx:1.21 image
2. Creates a pod with single container
3. Assigns IP address to pod
4. Container starts listening on port 80

### Example 2: Service Discovery

**Command Sequence:**
```bash
# 1. Create service
kubectl apply -f 02-nginx-service.yaml

# 2. Verify service creation
kubectl get services

# 3. Check endpoints
kubectl get endpoints nginx-service

# 4. Test service accessibility
kubectl port-forward service/nginx-service 8080:80
```

**Key Observations:**
- Service creates stable DNS name: `nginx-service.default.svc.cluster.local`
- Service load balances to all pods matching selector
- Endpoints show actual pod IPs behind service

### Example 3: Multi-tier Application

**Architecture Flow:**
```
Frontend (nginx) → Backend (nginx+content) → Redis (database)
       ↓                    ↓                     ↓
   Port 80            Port 8080              Port 6379
```

**Deployment Steps:**
```bash
# 1. Database layer
kubectl apply -f 05-redis-deployment.yaml

# 2. Backend layer with configuration
kubectl apply -f 09-backend-content.yaml
kubectl apply -f 06-backend-deployment.yaml

# 3. Configuration for frontend
kubectl apply -f 08-nginx-configmap.yaml

# 4. Frontend layer
kubectl apply -f 07-frontend-deployment.yaml
```

**Communication Pattern:**
1. User → Frontend Service
2. Frontend → Backend Service (via /api/ proxy)
3. Backend → Redis Service (via environment variable)

---

## 🏗️ Architecture Deep Dive

### Complete Application Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Kubernetes Cluster                       │
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                  Default Namespace                       ││
│  │                                                         ││
│  │  ┌─────────────┐    ┌─────────────┐    ┌──────────────┐││
│  │  │  Frontend   │    │   Backend   │    │    Redis     │││
│  │  │ Deployment  │    │ Deployment  │    │  Deployment  │││
│  │  │             │    │             │    │              │││
│  │  │ ┌─────────┐ │    │ ┌─────────┐ │    │ ┌──────────┐ │││
│  │  │ │nginx:1.21│ │    │ │nginx:1.21│ │    │ │redis:7   │ │││
│  │  │ │Port: 80 │ │    │ │Port: 80 │ │    │ │Port: 6379│ │││
│  │  │ │Replicas:2│ │    │ │Replicas:2│ │    │ │Replicas:1│ │││
│  │  │ └─────────┘ │    │ └─────────┘ │    │ └──────────┘ │││
│  │  └─────────────┘    └─────────────┘    └──────────────┘││
│  │         │                   │                    │     ││
│  │         ▼                   ▼                    ▼     ││
│  │  ┌─────────────┐    ┌─────────────┐    ┌──────────────┐││
│  │  │  Frontend   │    │   Backend   │    │    Redis     │││
│  │  │   Service   │    │   Service   │    │   Service    │││
│  │  │             │    │             │    │              │││
│  │  │ ClusterIP   │    │ ClusterIP   │    │  ClusterIP   │││
│  │  │ Port: 80    │    │ Port: 8080  │    │  Port: 6379  │││
│  │  └─────────────┘    └─────────────┘    └──────────────┘││
│  └─────────────────────────────────────────────────────────┘│
│                                                             │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                Monitoring Namespace                      ││
│  │                                                         ││
│  │  ┌─────────────┐    ┌─────────────┐    ┌──────────────┐││
│  │  │ Prometheus  │    │   Grafana   │    │ Alertmanager │││
│  │  │   Stack     │    │  Dashboard  │    │   Service    │││
│  │  │ Port: 9090  │    │ Port: 3000  │    │ Port: 9093   │││
│  │  └─────────────┘    └─────────────┘    └──────────────┘││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Network Flow Analysis

**Request Path:**
1. **External Request** → `kubectl port-forward frontend-service 8080:80`
2. **Frontend Service** → Load balances to frontend pods
3. **Frontend Pod** → nginx processes request
4. **API Proxy** → `/api/` requests forwarded to backend-service:8080
5. **Backend Service** → Load balances to backend pods
6. **Backend Pod** → Connects to redis-service:6379
7. **Redis Service** → Routes to Redis pod

**DNS Resolution:**
- `backend-service` → `backend-service.default.svc.cluster.local`
- `redis-service` → `redis-service.default.svc.cluster.local`

---

## ⚙️ Configuration Management Patterns

### ConfigMap Deep Dive

**Example: `08-nginx-configmap.yaml`**
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  default.conf: |              # Multi-line configuration file
    server {
        listen       80;
        server_name  localhost;
        
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
        
        location /api/ {         # Reverse proxy configuration
            proxy_pass http://backend-service:8080/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }
```

**ConfigMap Usage Patterns:**

1. **Environment Variables**
```yaml
env:
- name: CONFIG_VALUE
  valueFrom:
    configMapKeyRef:
      name: my-config
      key: config.value
```

2. **Volume Mounts**
```yaml
volumeMounts:
- name: config-volume
  mountPath: /etc/nginx/conf.d/
volumes:
- name: config-volume
  configMap:
    name: nginx-config
```

3. **Subpath Mounting**
```yaml
volumeMounts:
- name: backend-content
  mountPath: /usr/share/nginx/html/index.html
  subPath: index.html              # Mount only specific file
```

### Environment Variable Patterns

**From `06-backend-deployment.yaml`:**
```yaml
env:
- name: REDIS_HOST
  value: "redis-service"           # Service DNS name
```

**Advanced Environment Patterns:**
```yaml
env:
- name: SECRET_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password

- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP

- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
```

---

## 🌐 Service Communication & Networking

### Service Types & Use Cases

#### 1. ClusterIP (Default)
```yaml
apiVersion: v1
kind: Service
spec:
  type: ClusterIP                  # Internal cluster access only
  selector:
    app: backend
  ports:
  - port: 8080                     # Service port
    targetPort: 80                 # Container port
```

**Use Cases:**
- Internal service communication
- Database connections
- API backends

#### 2. NodePort
```yaml
apiVersion: v1
kind: Service
spec:
  type: NodePort
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080                # External access via node:30080
```

**Use Cases:**
- Development environments
- Quick external access
- Load balancer health checks

#### 3. LoadBalancer
```yaml
apiVersion: v1
kind: Service
spec:
  type: LoadBalancer              # Cloud provider creates LB
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
```

**Use Cases:**
- Production external access
- Cloud environments
- Automatic SSL termination

### Service Discovery Mechanisms

**DNS-based Discovery:**
```bash
# From within cluster:
curl http://backend-service:8080/
curl http://backend-service.default.svc.cluster.local:8080/

# Cross-namespace:
curl http://service-name.namespace-name.svc.cluster.local:port/
```

**Environment Variable Discovery:**
```bash
# Kubernetes injects these automatically:
BACKEND_SERVICE_HOST=10.96.1.1
BACKEND_SERVICE_PORT=8080
```

---

## 📏 Resource Management & Best Practices

### Resource Requests vs Limits

**From `03-nginx-deployment.yaml`:**
```yaml
resources:
  requests:                        # Minimum guaranteed resources
    memory: "64Mi"                # 64 Mebibytes
    cpu: "250m"                   # 250 millicores (0.25 CPU)
  limits:                         # Maximum allowed resources
    memory: "128Mi"               # Hard limit
    cpu: "500m"                   # CPU throttling point
```

### Resource Management Strategy

| Resource Type | Requests | Limits | Purpose |
|---------------|----------|---------|---------|
| **CPU** | Scheduling guarantee | Throttling point | Performance consistency |
| **Memory** | Minimum allocation | OOMKill threshold | Memory protection |

### Quality of Service (QoS) Classes

1. **Guaranteed**
   - All containers have CPU & memory requests = limits
   - Highest priority for scheduling
   - Last to be evicted

2. **Burstable**
   - Some containers have requests < limits
   - Medium priority
   - Can use additional resources when available

3. **BestEffort**
   - No requests or limits specified
   - Lowest priority
   - First to be evicted under pressure

### Practical Resource Sizing Guidelines

**Web Frontend (nginx):**
```yaml
resources:
  requests:
    memory: "64Mi"
    cpu: "100m"
  limits:
    memory: "128Mi"
    cpu: "200m"
```

**API Backend:**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "200m"
  limits:
    memory: "256Mi"
    cpu: "500m"
```

**Database (Redis):**
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

---

## 📊 Monitoring & Observability

### Prometheus Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Application │    │   Node      │    │  Kubernetes │
│  Metrics    │───▶│  Exporter   │───▶│   Metrics   │
│ (Custom)    │    │ (Hardware)  │    │  (API)      │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────────────────────────────────────────────┐
│                 Prometheus                          │
│              (Metrics Collection)                   │
└─────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Grafana   │    │ Alertmanager│    │   Other     │
│(Dashboards) │    │  (Alerts)   │    │  Consumers  │
└─────────────┘    └─────────────┘    └─────────────┘
```

### Key Metrics to Monitor

**Cluster Level:**
```promql
# Cluster resource utilization
(1 - (node_memory_MemFree_bytes + node_memory_Cached_bytes + node_memory_Buffers_bytes) / node_memory_MemTotal_bytes) * 100

# Pod count per node
count by (node) (kube_pod_info)

# Node CPU usage
100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Application Level:**
```promql
# Pod restart count
increase(kube_pod_container_status_restarts_total[1h])

# Container CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Container memory usage
container_memory_usage_bytes / container_spec_memory_limit_bytes * 100
```

**Network Level:**
```promql
# Network I/O
rate(container_network_receive_bytes_total[5m])
rate(container_network_transmit_bytes_total[5m])

# Service endpoint availability
up{job="kubernetes-services"}
```

### Grafana Dashboard Examples

**Cluster Overview Dashboard Queries:**
```promql
# Total pods running
sum(kube_pod_status_phase{phase="Running"})

# Memory utilization
(sum(container_memory_usage_bytes) / sum(container_spec_memory_limit_bytes)) * 100

# CPU utilization
sum(rate(container_cpu_usage_seconds_total[5m])) / sum(container_spec_cpu_quota / container_spec_cpu_period) * 100
```

---

## 🔧 Troubleshooting Scenarios

### Common Issue Patterns & Solutions

#### 1. Pod Stuck in Pending State

**Symptoms:**
```bash
kubectl get pods
NAME                    READY   STATUS    RESTARTS   AGE
nginx-deployment-xxx    0/1     Pending   0          5m
```

**Diagnosis Commands:**
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check node resources
kubectl top nodes
kubectl describe nodes

# Check resource quotas
kubectl describe resourcequota
```

**Common Causes & Solutions:**
- **Insufficient Resources:** Scale down other workloads or add nodes
- **Node Selector Issues:** Check nodeSelector constraints
- **Affinity Rules:** Verify pod affinity/anti-affinity rules
- **Taints/Tolerations:** Check node taints and pod tolerations

#### 2. Service Not Accessible

**Symptoms:**
```bash
curl: (7) Failed to connect to service-name:80
```

**Diagnosis Commands:**
```bash
# Check service configuration
kubectl get svc <service-name> -o yaml

# Verify endpoints
kubectl get endpoints <service-name>

# Check pod labels
kubectl get pods --show-labels

# Test DNS resolution
kubectl run test-pod --image=busybox -it --rm -- nslookup <service-name>
```

**Common Causes & Solutions:**
- **Label Mismatch:** Ensure service selector matches pod labels
- **Wrong Port:** Verify targetPort matches container port
- **No Healthy Pods:** Check pod readiness probes
- **Network Policies:** Review network policy rules

#### 3. Application Crashes/Restarts

**Symptoms:**
```bash
kubectl get pods
NAME                    READY   STATUS             RESTARTS   AGE
backend-deployment-xxx  0/1     CrashLoopBackOff   5          10m
```

**Diagnosis Commands:**
```bash
# Check current logs
kubectl logs <pod-name>

# Check previous container logs
kubectl logs <pod-name> --previous

# Describe pod for events
kubectl describe pod <pod-name>

# Check resource usage
kubectl top pod <pod-name>
```

**Common Causes & Solutions:**
- **OOMKilled:** Increase memory limits
- **Configuration Error:** Check ConfigMaps and environment variables
- **Dependency Issues:** Verify service dependencies are running
- **Health Check Failures:** Review liveness/readiness probe configurations

#### 4. Performance Issues

**Diagnosis Approach:**
```bash
# Resource utilization
kubectl top nodes
kubectl top pods

# Check resource limits
kubectl get pods -o yaml | grep -A 6 resources:

# Monitor metrics with Prometheus
# CPU: rate(container_cpu_usage_seconds_total[5m])
# Memory: container_memory_usage_bytes

# Network latency testing
kubectl run netshoot --image=nicolaka/netshoot -it --rm
```

### Troubleshooting Workflow

```
Issue Reported
      ↓
Check Pod Status
      ↓
┌─────────────────┬─────────────────┬─────────────────┐
│    Pending      │  CrashLoopBack  │    Running      │
│       ↓         │       ↓         │       ↓         │
│ Check Resources │  Check Logs     │ Check Performance│
│ Check Scheduling│  Check Config   │ Check Monitoring │
│ Check Nodes     │  Check Probes   │ Check Logs      │
└─────────────────┴─────────────────┴─────────────────┘
      ↓                   ↓                   ↓
Apply Fix           Apply Fix           Apply Fix
      ↓                   ↓                   ↓
    Verify            Verify            Verify
```

---

## 🚀 Advanced Concepts & Next Steps

### 1. Advanced Workload Types

#### StatefulSets
```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis-cluster
spec:
  serviceName: redis-headless
  replicas: 3
  template:
    spec:
      containers:
      - name: redis
        image: redis:7
        volumeMounts:
        - name: data
          mountPath: /data
  volumeClaimTemplates:          # Persistent storage per pod
  - metadata:
      name: data
    spec:
      accessModes: ["ReadWriteOnce"]
      resources:
        requests:
          storage: 1Gi
```

**Use Cases:**
- Databases (MySQL, PostgreSQL, MongoDB)
- Message queues (Kafka, RabbitMQ)
- Distributed systems requiring stable identity

#### DaemonSets
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: logging-agent
spec:
  selector:
    matchLabels:
      name: logging-agent
  template:
    spec:
      containers:
      - name: fluentd
        image: fluentd:v1.14
        volumeMounts:
        - name: varlog
          mountPath: /var/log
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

**Use Cases:**
- Log collection (Fluentd, Filebeat)
- Monitoring agents (Node Exporter, Datadog)
- Network plugins (Calico, Flannel)

### 2. Storage Patterns

#### Persistent Volumes
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: postgres-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /data/postgres
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### 3. Security Patterns

#### RBAC Configuration
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: User
  name: jane
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

#### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
spec:
  podSelector: {}                # Applies to all pods
  policyTypes:
  - Ingress
  # No ingress rules = deny all ingress
```

### 4. Automation Patterns

#### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: backend-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: backend-deployment
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

#### CronJobs
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"          # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: backup-tool:latest
            command:
            - /bin/bash
            - -c
            - backup-database.sh
          restartPolicy: OnFailure
```

---

## 💻 Practical Commands Reference

### Daily Operations Commands

#### Cluster Management
```bash
# Cluster info
kubectl cluster-info
kubectl get nodes -o wide
kubectl top nodes

# Namespace operations
kubectl get namespaces
kubectl create namespace monitoring
kubectl config set-context --current --namespace=monitoring
```

#### Workload Management
```bash
# Deployments
kubectl get deployments
kubectl scale deployment backend-deployment --replicas=5
kubectl rollout status deployment/backend-deployment
kubectl rollout history deployment/backend-deployment
kubectl rollout undo deployment/backend-deployment

# Pods
kubectl get pods -o wide
kubectl get pods --field-selector=status.phase=Running
kubectl get pods --selector app=backend
kubectl logs -f deployment/backend-deployment
kubectl exec -it <pod-name> -- /bin/bash
```

#### Service and Networking
```bash
# Services
kubectl get services
kubectl get endpoints
kubectl port-forward service/frontend-service 8080:80
kubectl expose deployment backend-deployment --port=8080 --target-port=80

# Ingress
kubectl get ingress
kubectl describe ingress <ingress-name>
```

#### Configuration and Storage
```bash
# ConfigMaps and Secrets
kubectl get configmaps
kubectl create configmap app-config --from-file=config.yaml
kubectl get secrets
kubectl create secret generic db-secret --from-literal=password=secret123

# Persistent Storage
kubectl get pv
kubectl get pvc
kubectl describe pv <pv-name>
```

#### Debugging and Troubleshooting
```bash
# Events and describe
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl describe pod <pod-name>
kubectl describe node <node-name>

# Resource usage
kubectl top pods
kubectl top nodes
kubectl top pods --containers

# Network debugging
kubectl run debug --image=nicolaka/netshoot -it --rm
kubectl run busybox --image=busybox -it --rm -- /bin/sh
```

### Advanced Operations

#### Batch Operations
```bash
# Apply multiple files
kubectl apply -f ./
kubectl apply -k ./kustomize/

# Delete resources
kubectl delete -f deployment.yaml
kubectl delete deployment,service -l app=backend

# Batch resource updates
kubectl get pods -o name | xargs kubectl delete
kubectl patch deployment backend -p '{"spec":{"replicas":3}}'
```

#### Monitoring and Metrics
```bash
# Resource monitoring
kubectl top pods --all-namespaces
kubectl top nodes --use-protocol-buffers

# Get resource definitions
kubectl explain pod.spec
kubectl explain service.spec.ports

# API resources
kubectl api-resources
kubectl api-versions
```

---

## 🎤 Interview Preparation

### Fundamental Questions & Answers

#### Q1: "Explain the difference between a Pod and a Deployment"

**Answer:**
- **Pod**: Smallest deployable unit, contains one or more containers, ephemeral
- **Deployment**: Manages multiple pod replicas, provides rolling updates, self-healing
- **Key Difference**: Deployments ensure desired state and manage pod lifecycle

**Follow-up Code:**
```yaml
# Pod - direct pod creation (not recommended for production)
apiVersion: v1
kind: Pod
metadata:
  name: single-pod
spec:
  containers:
  - name: nginx
    image: nginx

# Deployment - manages pods (production pattern)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
```

#### Q2: "How does service discovery work in Kubernetes?"

**Answer:**
- **DNS-based**: Services get DNS names (service-name.namespace.svc.cluster.local)
- **Environment Variables**: Kubernetes injects SERVICE_HOST and SERVICE_PORT
- **Labels and Selectors**: Services use selectors to find target pods

**Practical Example:**
```bash
# From frontend pod, access backend service:
curl http://backend-service:8080/api/data

# Full DNS name:
curl http://backend-service.default.svc.cluster.local:8080/api/data
```

#### Q3: "What are the different types of Kubernetes services?"

**Answer:**
- **ClusterIP**: Internal cluster communication only (default)
- **NodePort**: Exposes service on each node's IP at a static port
- **LoadBalancer**: Creates cloud provider load balancer
- **ExternalName**: Maps service to external DNS name

#### Q4: "Explain resource requests vs limits"

**Answer:**
- **Requests**: Minimum guaranteed resources for scheduling decisions
- **Limits**: Maximum resources a container can use (hard cap)
- **QoS Classes**: Guaranteed (requests=limits), Burstable (requests<limits), BestEffort (no requests/limits)

#### Q5: "How would you debug a pod that's not starting?"

**Answer:**
```bash
# 1. Check pod status and events
kubectl get pods
kubectl describe pod <pod-name>

# 2. Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous

# 3. Check resource constraints
kubectl top nodes
kubectl get resourcequota

# 4. Check node scheduling
kubectl get nodes
kubectl describe node <node-name>
```

### Scenario-Based Questions

#### Scenario 1: "Application is running but users can't access it"

**Troubleshooting Steps:**
1. Check service configuration and endpoints
2. Verify pod labels match service selector
3. Test internal connectivity (port-forward)
4. Check ingress/load balancer configuration
5. Verify network policies

#### Scenario 2: "Pods keep restarting"

**Investigation Process:**
1. Check application logs for errors
2. Verify resource limits (CPU/memory)
3. Check health probe configurations
4. Investigate external dependencies
5. Review application configuration

#### Scenario 3: "How would you implement blue-green deployment?"

**Implementation Strategy:**
```yaml
# Blue deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-blue
  labels:
    version: blue
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
      version: blue

# Service initially points to blue
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: myapp
    version: blue  # Switch to "green" for deployment

# Switch traffic by updating service selector
kubectl patch service app-service -p '{"spec":{"selector":{"version":"green"}}}'
```

### Advanced Topics for Senior Roles

#### Custom Resource Definitions (CRDs)
```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: databases.stable.example.com
spec:
  group: stable.example.com
  versions:
  - name: v1
    served: true
    storage: true
    schema:
      openAPIV3Schema:
        type: object
        properties:
          spec:
            type: object
            properties:
              size:
                type: string
              version:
                type: string
  scope: Namespaced
  names:
    plural: databases
    singular: database
    kind: Database
```

#### Operators and Controllers
- **Purpose**: Automate complex application management
- **Components**: CRDs + Controllers + Operational Knowledge
- **Examples**: Prometheus Operator, MongoDB Operator

### Performance and Optimization Questions

#### Q: "How would you optimize Kubernetes cluster performance?"

**Answer Areas:**
1. **Resource Management**: Proper requests/limits, QoS classes
2. **Node Optimization**: Node sizing, kernel parameters
3. **Network**: CNI optimization, service mesh considerations
4. **Storage**: PV/PVC optimization, storage classes
5. **Monitoring**: Prometheus, metrics analysis

#### Q: "Explain Kubernetes networking"

**Answer Components:**
1. **Pod-to-Pod**: Flat network, every pod gets unique IP
2. **Pod-to-Service**: kube-proxy handles load balancing
3. **External Traffic**: Ingress controllers, load balancers
4. **CNI**: Container Network Interface plugins (Calico, Flannel)
5. **Network Policies**: Firewall rules for pods

---

## 🎯 Practical Learning Exercises

### Exercise 1: Multi-tier Application Deployment
**Objective**: Deploy and connect frontend, backend, and database

**Steps:**
1. Deploy Redis database with persistent storage
2. Create backend API that connects to Redis
3. Deploy frontend that proxies API requests
4. Configure monitoring for all components
5. Test end-to-end connectivity

### Exercise 2: Scaling and Load Testing
**Objective**: Implement horizontal scaling

**Tasks:**
1. Configure HPA for backend service
2. Generate load using load testing tool
3. Observe scaling behavior
4. Tune HPA parameters
5. Document scaling patterns

### Exercise 3: Configuration Management
**Objective**: Externalize all configuration

**Requirements:**
1. Move all hardcoded values to ConfigMaps
2. Implement secret management for sensitive data
3. Support multiple environments (dev/staging/prod)
4. Implement configuration hot-reloading

### Exercise 4: Disaster Recovery
**Objective**: Implement backup and recovery procedures

**Components:**
1. Database backup strategy
2. Configuration backup (GitOps)
3. Disaster recovery runbook
4. Recovery testing procedures

---

## 📈 Learning Path Progression

### Beginner (Weeks 1-2)
- ✅ Understand pods, services, deployments
- ✅ Complete basic examples (files 01-04)
- ✅ Learn kubectl basic commands
- ✅ Set up local Minikube environment

### Intermediate (Weeks 3-4)
- ✅ Deploy multi-tier application (files 05-09)
- ✅ Understand ConfigMaps and environment variables
- ✅ Learn service discovery and networking
- ✅ Implement basic monitoring

### Advanced (Weeks 5-6)
- ✅ Implement persistent storage
- ✅ Configure security (RBAC, Network Policies)
- ✅ Set up CI/CD pipelines
- ✅ Performance tuning and optimization

### Expert (Ongoing)
- ✅ Custom resources and operators
- ✅ Multi-cluster management
- ✅ Advanced networking (service mesh)
- ✅ Production operations and troubleshooting

---

## 🔗 Additional Resources

### Official Documentation
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [API Reference](https://kubernetes.io/docs/reference/kubernetes-api/)

### Learning Platforms
- [Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [Play with Kubernetes](https://labs.play-with-k8s.com/)
- [Katacoda Kubernetes](https://www.katacoda.com/courses/kubernetes)

### Tools and Utilities
- [k9s](https://k9scli.io/) - Terminal UI for Kubernetes
- [Lens](https://k8slens.dev/) - Kubernetes IDE
- [Helm](https://helm.sh/) - Package manager
- [Kustomize](https://kustomize.io/) - Configuration management

### Best Practices
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [12-Factor App](https://12factor.net/)
- [CNCF Landscape](https://landscape.cncf.io/)

---

## ✅ Final Checklist

### Knowledge Verification

**Core Concepts** ✓
- [ ] Can explain pod, service, deployment relationships
- [ ] Understand service discovery mechanisms
- [ ] Know resource management patterns
- [ ] Familiar with configuration management

**Practical Skills** ✓
- [ ] Can deploy multi-tier applications
- [ ] Able to troubleshoot common issues
- [ ] Comfortable with kubectl commands
- [ ] Can implement monitoring solutions

**Advanced Topics** ✓
- [ ] Understand storage patterns
- [ ] Know security best practices
- [ ] Familiar with scaling strategies
- [ ] Can implement CI/CD workflows

**Production Readiness** ✓
- [ ] Know operational procedures
- [ ] Can implement disaster recovery
- [ ] Understand performance optimization
- [ ] Familiar with cost management

---

**🎉 Congratulations!** 

You now have a comprehensive understanding of Kubernetes concepts and practical implementations. Continue practicing with real-world scenarios and stay updated with the rapidly evolving Kubernetes ecosystem.

**Remember**: The key to mastering Kubernetes is hands-on practice. Keep experimenting, breaking things, and fixing them. This learning project provides a solid foundation for your Kubernetes journey!