# 🚀 ArgoCD Project - Full Stack CI/CD with Kubernetes & GitOps

## 📌 Project Overview
This project demonstrates a complete **CI/CD pipeline** using modern DevOps tools.  
I built a full-stack authentication system and deployed it using Docker and Kubernetes, while managing deployments using ArgoCD (GitOps approach).

---

## ⚙️ Tools & Technologies

- **Frontend:** React + TypeScript  
- **Backend:** Node.js + Express.js  
- **Containerization:** Docker  
- **Orchestration:** Kubernetes (Minikube)  
- **Web Server:** Nginx (Reverse Proxy)  
- **CI Tool:** GitHub Actions  
- **CD Tool:** ArgoCD  
- **Database:** MongoDB  


---

## 🔧 Implementation Steps

### 1️⃣ Application Development
- Created a simple authentication system (Signup/Login)
- Backend: Node.js + Express.js  
- Frontend: React + TypeScript  

---

### 2️⃣ Dockerization
- Created Dockerfiles for frontend and backend  
- Built local images:
  - `argocd-backend`
  - `argocd-frontend`  
- Pushed images to Docker Hub:
  - `kanchana20/argocd-backend`
  - `kanchana20/argocd-frontend`

---

### 3️⃣ Nginx Configuration
- Served static frontend files  
- Configured reverse proxy to backend API  

---

### 4️⃣ Kubernetes Setup
- Used Minikube to create a local cluster  
- Created Kubernetes manifests in `k8s/` folder:
   - backend-deployment.yaml
   - backend-service.yaml
   - frontend-deployment.yaml
   - frontend-service.yaml
   - mongo-deployment.yaml
   - mongo-service.yaml
  
- Deployments manage Pods  
- Services expose applications and enable communication  

---

### 5️⃣ ArgoCD Setup
- Created namespace: `argocd`  
- Installed ArgoCD inside the cluster  
- Accessed ArgoCD UI using port-forward  

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
- Accessed ArgoCD UI using port-forward

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```
## 🔄 CI/CD Pipeline (GitOps)
- **CI - GitHub Actions**

- On every push to main branch:

  - Build Docker images
  - Tag images using Git commit hash
  - Push images to Docker Hub
  - Update Kubernetes manifests with new image tags
  - Commit and push updated manifests back to repo
---
- **CD - ArgoCD**
  - Monitors GitHub repository
  - Detects manifest changes
  - Automatically deploys updated application to Kubernetes
---

- **Result**
  ```bash
  git push origin main
  ```
- ➡️ Automatically triggers full CI/CD pipeline
  
---

## 🌐 Running the Project Locally
- Step 1: Start Minikube
  ```bash
  minikube start --driver=docker
  ```
- Step 2: Access Application
  ```bash
  minikube service frontend
  ```
- Step 3: Open ArgoCD Dashboard
  ```bash
  kubectl port-forward svc/argocd-server -n argocd 8080:443
  ```
  - Open in browser:
    ```bash
    https://localhost:8080
    ```
---
## 🧠 Problem & Solution
- ❌ Problem
  
  - User data was lost after restarting Minikube
  - MongoDB Pod restart caused data loss
    
- 🔍 Root Cause
  - Pods do not have persistent storage by default
- ✅ Solution
  - Implemented Persistent Volume (PV)
  - Mounted it to MongoDB Pod
  - Ensured data persistence across restarts
---
## 🎯 Key Learnings
- Docker containerization
- Kubernetes core concepts (Pods, Deployments, Services)
- Internal networking in Kubernetes
- Nginx reverse proxy configuration
- GitOps workflow using ArgoCD
- CI automation using GitHub Actions
- Data persistence using Persistent Volumes
---

## 👨‍💻 Author

**Kanchana Koralage**
- GitHub: https://github.com/KanchanaKoralage1
- LinkedIn: https://www.linkedin.com/in/kanchana-koralage/
- Email: itsmekanchanakoralage@gmail.com
