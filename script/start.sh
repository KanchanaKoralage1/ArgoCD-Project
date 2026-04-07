#!/bin/bash

# ─────────────────────────────────────────
# ArgoCD Project — Robust One Click Startup
# ─────────────────────────────────────────

echo "╔════════════════════════════════════╗"
echo "║   ArgoCD Project Startup Script    ║"
echo "╚════════════════════════════════════╝"
echo ""

# ── Step 1: Start Minikube ───────────────────────────────
echo "Starting Minikube..."
minikube start --driver=docker

if [ $? -ne 0 ]; then
    echo "Minikube failed to start. Check Docker is running!"
    exit 1
fi

echo "Minikube started successfully!"
echo ""

# ── Step 2: Wait for cluster to be ready ─────────────────
echo "Waiting for cluster to stabilize..."
sleep 15

# ── Step 3: Deploy default apps using Helm ──────────────
echo "Deploying applications via Helm..."

# Get the path to the root folder (parent of script folder)
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

helm upgrade --install argocd-project "$ROOT_DIR/helm" \
  --namespace default \
  --create-namespace \
  --values "$ROOT_DIR/helm/values.yaml"

if [ $? -ne 0 ]; then
    echo "❌ Helm deployment failed. Check Helm chart and values.yaml"
    exit 1
fi

echo "Helm deployment successful!"
echo ""

# ── Step 4: Wait until all default pods are running ─────
echo "Waiting for all default namespace pods to be ready..."
until [ "$(kubectl get pods -n default --no-headers 2>/dev/null | grep -v Running | wc -l)" -eq 0 ]; do
    echo "Pods not ready yet... waiting 5 seconds"
    sleep 5
done

echo "All default namespace pods are running!"
echo ""

# ── Step 5: Check and fix ArgoCD pods ───────────────────
echo "Checking ArgoCD pods..."
BROKEN=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error|Completed")

if [ -n "$BROKEN" ]; then
    echo "Found broken ArgoCD pods — restarting..."
    kubectl rollout restart deployment/argocd-repo-server -n argocd
    kubectl rollout restart deployment/argocd-server -n argocd
    echo "Waiting for ArgoCD to recover..."
    sleep 30
else
    echo "All ArgoCD pods are healthy!"
fi

# ── Step 6: Show current pod status ─────────────────────
echo ""
echo "Current pod status:"
kubectl get pods --all-namespaces
echo ""

# ── Step 7: Open ArgoCD dashboard in background ─────────
echo "Starting ArgoCD dashboard..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 & > /dev/null &
ARGOCD_PID=$!
sleep 3
echo "ArgoCD dashboard running at https://localhost:8080"
echo "Username: admin"
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode)"

# ── Step 8: Open frontend app via Minikube ─────────────
echo ""
echo "Opening frontend app..."
FRONTEND_SERVICE=$(kubectl get svc -n default | grep frontend | awk '{print $1}')
if [ -n "$FRONTEND_SERVICE" ]; then
    minikube service "$FRONTEND_SERVICE" --namespace default &
    APP_PID=$!
    sleep 3
else
    echo "❌ Frontend service not found in default namespace."
fi

# ── Step 9: Done ───────────────────────────────────────
echo "✅ All services are up and running!"
echo ""

# ── Step 10: Auto monitor ArgoCD pods every 60s ────────
while true; do
    sleep 60
    BROKEN=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error|Completed")
    if [ -n "$BROKEN" ]; then
        echo "Auto-detected broken ArgoCD pod — restarting..."
        kubectl rollout restart deployment/argocd-repo-server -n argocd
    fi
done