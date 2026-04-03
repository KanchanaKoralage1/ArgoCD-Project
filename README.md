# 🚀 ArgoCD Project - Full Stack CI/CD with Kubernetes & GitOps

## 📌 Project Overview
This project demonstrates a complete **CI/CD pipeline** using modern DevOps tools.  
I built a full-stack authentication system and deployed it using Docker and Kubernetes, while managing deployments using ArgoCD (GitOps approach).

---
## 📸 Screenshots
<img width="1677" height="882" alt="Web app 1" src="https://github.com/user-attachments/assets/9f4840f9-0531-4e24-bae8-ce6c22069938" />
<img width="1685" height="837" alt="Web app 2" src="https://github.com/user-attachments/assets/012bfe5b-9f69-4629-91a4-ec1111b3e8f7" />
<img width="1920" height="949" alt="ArgoCD Dashboard 1" src="https://github.com/user-attachments/assets/dcb3e5d2-17ce-4489-ae5e-04434726082c" />
<img width="1914" height="942" alt="Argocd Dashboard 2" src="https://github.com/user-attachments/assets/693cb8b5-47aa-489e-8f84-8becb974e311" />
<img width="1904" height="735" alt="Docker image 1" src="https://github.com/user-attachments/assets/561cccfc-d941-4d5d-8877-7168cf680195" />
<img width="1902" height="922" alt="Docker image 2" src="https://github.com/user-attachments/assets/b8fdc21b-f030-474e-a9f1-149bc8f53f25" />
<img width="1909" height="908" alt="Terminal 3" src="https://github.com/user-attachments/assets/d9d6dc0f-92a7-4340-a73d-8880a09fabef" />
<img width="1192" height="1012" alt="Terminal 1" src="https://github.com/user-attachments/assets/b8d735b9-0988-48ea-986a-5cd3eaedc4a3" />
<img width="1020" height="408" alt="Terminal 2" src="https://github.com/user-attachments/assets/47be3199-f2f6-4f8b-b653-c9f13d9a760b" />

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
