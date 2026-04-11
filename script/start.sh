#!/bin/bash

# ─────────────────────────────────────────────────────
# ArgoCD Project — One Click Startup Script
# Starts: Minikube, ArgoCD, App, Prometheus, Grafana
# Run from Git Bash: ./start.sh
# ─────────────────────────────────────────────────────

echo "╔══════════════════════════════════════════════╗"
echo "║       ArgoCD Project Startup Script          ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Step 1: Start Minikube ───────────────────────────
echo "► Starting Minikube..."
minikube start --driver=docker

if [ $? -ne 0 ]; then
    echo "✗ Minikube failed to start. Is Docker running?"
    exit 1
fi
echo "✓ Minikube started!"
echo ""

# ── Step 2: Wait for cluster to stabilize ────────────
echo "► Waiting for cluster to stabilize..."
sleep 15

# ── Step 3: Check and fix ArgoCD pods ────────────────
echo "► Checking ArgoCD pods..."

wait_for_argocd() {
    echo "  Waiting for ArgoCD repo-server to be ready..."
    local attempts=0
    until kubectl get pods -n argocd | grep "argocd-repo-server" | grep "1/1" > /dev/null 2>&1; do
        attempts=$((attempts + 1))
        if [ $attempts -gt 24 ]; then
            echo "  ✗ ArgoCD repo-server taking too long — continuing anyway"
            break
        fi
        echo "  ArgoCD repo-server not ready yet... waiting 5 seconds"
        sleep 5
    done
    echo "  ✓ ArgoCD repo-server is ready!"
}

BROKEN=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error|Completed")

if [ -n "$BROKEN" ]; then
    echo "  Found broken ArgoCD pods — restarting..."
    kubectl rollout restart deployment/argocd-repo-server -n argocd
    kubectl rollout restart deployment/argocd-server -n argocd
    sleep 10
    wait_for_argocd
else
    echo "  ✓ All ArgoCD pods are healthy!"
fi

# ── Step 4: Check and fix default app pods ───────────
echo ""
echo "► Checking app pods..."

BROKEN_APPS=$(kubectl get pods -n default --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error")

if [ -n "$BROKEN_APPS" ]; then
    echo "  Found broken app pods — restarting..."
    kubectl rollout restart deployment/backend -n default 2>/dev/null
    kubectl rollout restart deployment/frontend -n default 2>/dev/null
    kubectl rollout restart deployment/mongo -n default 2>/dev/null
    echo "  Waiting for app pods to recover..."
    sleep 20
fi

echo "  Waiting for all app pods to be ready..."
attempts=0
until [ "$(kubectl get pods -n default --no-headers 2>/dev/null | grep -v Running | grep -v Completed | wc -l)" -eq 0 ]; do
    attempts=$((attempts + 1))
    if [ $attempts -gt 30 ]; then
        echo "  ✗ Some pods taking too long — continuing anyway"
        break
    fi
    echo "  Pods not ready yet... waiting 5 seconds"
    sleep 5
done
echo "  ✓ All app pods are running!"

# ── Step 5: Check and fix monitoring pods ────────────
echo ""
echo "► Checking monitoring pods (Prometheus + Grafana)..."

BROKEN_MONITORING=$(kubectl get pods -n monitoring --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error|Completed")

if [ -n "$BROKEN_MONITORING" ]; then
    echo "  Found broken monitoring pods — restarting..."
    kubectl rollout restart deployment/grafana -n monitoring 2>/dev/null
    kubectl rollout restart deployment/prometheus-server -n monitoring 2>/dev/null
    sleep 15
fi

echo "  Waiting for monitoring pods to be ready..."
attempts=0
until [ "$(kubectl get pods -n monitoring --no-headers 2>/dev/null | grep -v Running | grep -v Completed | wc -l)" -eq 0 ]; do
    attempts=$((attempts + 1))
    if [ $attempts -gt 30 ]; then
        echo "  ✗ Monitoring pods taking too long — continuing anyway"
        break
    fi
    echo "  Monitoring pods not ready yet... waiting 5 seconds"
    sleep 5
done
echo "  ✓ All monitoring pods are running!"

# ── Step 6: Show current pod status ──────────────────
echo ""
echo "► Current pod status:"
echo ""
kubectl get pods --all-namespaces
echo ""

# ── Step 7: Start ArgoCD dashboard ───────────────────
echo "► Starting ArgoCD dashboard..."

PID_8080=$(lsof -ti:8080 2>/dev/null)
if [ -n "$PID_8080" ]; then
    kill $PID_8080 2>/dev/null
    sleep 2
fi

kubectl port-forward svc/argocd-server -n argocd 8080:443 > /tmp/argocd-portforward.log 2>&1 &
ARGOCD_PID=$!
sleep 5

if kill -0 $ARGOCD_PID 2>/dev/null; then
    echo "  ✓ ArgoCD dashboard: https://localhost:8080"
    start https://localhost:8080 2>/dev/null || true
else
    echo "  ✗ ArgoCD port-forward failed — try manually:"
    echo "    kubectl port-forward svc/argocd-server -n argocd 8080:443"
fi

# ── Step 8: Open frontend app ─────────────────────────
echo ""
echo "► Opening frontend app..."

if kubectl get svc frontend-service -n default > /dev/null 2>&1; then
    FRONTEND_SVC="frontend-service"
elif kubectl get svc frontend -n default > /dev/null 2>&1; then
    FRONTEND_SVC="frontend"
else
    echo "  ✗ No frontend service found!"
    FRONTEND_SVC=""
fi

if [ -n "$FRONTEND_SVC" ]; then
    echo "  Found service: $FRONTEND_SVC"
    minikube service $FRONTEND_SVC --namespace default &
    FRONTEND_PID=$!
    sleep 5
    echo "  ✓ Frontend app opened in browser!"
fi

# ── Step 9: Start Prometheus ──────────────────────────
echo ""
echo "► Starting Prometheus..."
minikube service prometheus-server -n monitoring &
PROMETHEUS_PID=$!
sleep 5
echo "  ✓ Prometheus opened in browser!"

# ── Step 10: Start Grafana ────────────────────────────
echo ""
echo "► Starting Grafana..."
minikube service grafana -n monitoring &
GRAFANA_PID=$!
sleep 5
echo "  ✓ Grafana opened in browser!"

# ── Step 11: Print summary ────────────────────────────
echo ""
echo "╔══════════════════════════════════════════════╗"
echo "║          Everything is running!              ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Frontend:   http://127.0.0.1:XXXXX          ║"
echo "║  ArgoCD:     https://localhost:8080          ║"
echo "║  Prometheus: http://127.0.0.1:XXXXX          ║"
echo "║  Grafana:    http://127.0.0.1:XXXXX          ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  ArgoCD  → username: admin                   ║"
echo "║  Grafana → username: admin                   ║"
echo "║  Grafana → password: admin123                ║"
echo "╠══════════════════════════════════════════════╣"
echo "║  Press Ctrl+C to stop everything            ║"
echo "╚══════════════════════════════════════════════╝"
echo ""

# ── Step 12: Cleanup on exit ─────────────────────────
cleanup() {
    echo ""
    echo "Stopping all background processes..."
    kill $ARGOCD_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    kill $PROMETHEUS_PID 2>/dev/null
    kill $GRAFANA_PID 2>/dev/null
    echo "Done! Run minikube stop to stop the cluster."
    exit 0
}

trap cleanup SIGINT SIGTERM

# ── Step 13: Auto-monitor every 60 seconds ───────────
echo "► Auto-monitoring pods every 60 seconds..."
echo "  (Press Ctrl+C to stop)"
echo ""

while true; do
    sleep 60

    # Check ArgoCD pods
    BROKEN=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error|Completed")
    if [ -n "$BROKEN" ]; then
        echo "$(date '+%H:%M:%S') — Broken ArgoCD pod detected — restarting repo-server..."
        kubectl rollout restart deployment/argocd-repo-server -n argocd > /dev/null 2>&1
    fi

    # Restart ArgoCD port-forward if died
    if ! kill -0 $ARGOCD_PID 2>/dev/null; then
        echo "$(date '+%H:%M:%S') — ArgoCD port-forward died — restarting..."
        kubectl port-forward svc/argocd-server -n argocd 8080:443 > /tmp/argocd-portforward.log 2>&1 &
        ARGOCD_PID=$!
    fi

    # Check monitoring pods
    BROKEN_MON=$(kubectl get pods -n monitoring --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error|Completed")
    if [ -n "$BROKEN_MON" ]; then
        echo "$(date '+%H:%M:%S') — Broken monitoring pod detected — restarting..."
        kubectl rollout restart deployment/grafana -n monitoring > /dev/null 2>&1
        kubectl rollout restart deployment/prometheus-server -n monitoring > /dev/null 2>&1
    fi

    # Check app pods
    BROKEN_APPS=$(kubectl get pods -n default --no-headers 2>/dev/null | grep -E "CrashLoopBackOff|Error")
    if [ -n "$BROKEN_APPS" ]; then
        echo "$(date '+%H:%M:%S') — Broken app pod detected — restarting..."
        kubectl rollout restart deployment/backend -n default > /dev/null 2>&1
        kubectl rollout restart deployment/frontend -n default > /dev/null 2>&1
    fi
done