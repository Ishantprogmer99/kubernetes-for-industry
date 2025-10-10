#!/bin/bash

# Kubernetes Learning Project Setup Script
echo "🚀 Setting up Kubernetes Learning Environment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Minikube is running
if ! minikube status &> /dev/null; then
    print_warning "Minikube is not running. Starting Minikube..."
    minikube start --driver=docker
    if [ $? -eq 0 ]; then
        print_status "Minikube started successfully"
    else
        print_error "Failed to start Minikube"
        exit 1
    fi
else
    print_status "Minikube is already running"
fi

# Enable metrics server
print_status "Enabling metrics server..."
minikube addons enable metrics-server

# Deploy application stack
print_status "Deploying application components..."

echo "📦 Deploying ConfigMaps..."
kubectl apply -f 08-nginx-configmap.yaml
kubectl apply -f 09-backend-content.yaml

echo "📦 Deploying Redis database..."
kubectl apply -f 05-redis-deployment.yaml

echo "📦 Deploying Backend API..."
kubectl apply -f 06-backend-deployment.yaml

echo "📦 Deploying Frontend..."
kubectl apply -f 07-frontend-deployment.yaml

# Wait for pods to be ready
print_status "Waiting for application pods to be ready..."
kubectl wait --for=condition=ready pod -l app=redis --timeout=120s
kubectl wait --for=condition=ready pod -l app=backend --timeout=120s
kubectl wait --for=condition=ready pod -l app=frontend --timeout=120s

# Create monitoring namespace if it doesn't exist
if ! kubectl get namespace monitoring &> /dev/null; then
    print_status "Creating monitoring namespace..."
    kubectl create namespace monitoring
fi

# Install Prometheus stack if not already installed
if ! helm list -n monitoring | grep -q prometheus-stack; then
    print_status "Installing Prometheus stack..."
    
    # Add Helm repo
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm repo update
    
    # Install Prometheus stack
    helm install prometheus-stack prometheus-community/kube-prometheus-stack \
        --namespace monitoring \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
    
    print_status "Waiting for monitoring stack to be ready..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana -n monitoring --timeout=300s
else
    print_status "Prometheus stack already installed"
fi

# Get Grafana password
GRAFANA_PASSWORD=$(kubectl --namespace monitoring get secrets prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 -d)

print_status "🎉 Setup complete!"
echo ""
echo "📊 Access your applications:"
echo ""
echo "🌐 Frontend Application:"
echo "   kubectl port-forward service/frontend-service 8081:80"
echo "   Then visit: http://localhost:8081"
echo ""
echo "📈 Grafana Dashboard:"
echo "   kubectl --namespace monitoring port-forward service/prometheus-stack-grafana 3000:80"
echo "   Then visit: http://localhost:3000"
echo "   Username: admin"
echo "   Password: ${GRAFANA_PASSWORD}"
echo ""
echo "🔍 Useful commands:"
echo "   kubectl get all                    # View all resources"
echo "   kubectl get pods -n monitoring    # View monitoring pods"
echo "   kubectl logs -f <pod-name>        # Follow pod logs"
echo ""
echo "Happy learning! 🚀"