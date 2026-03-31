import axios from 'axios'

const API = axios.create({
  baseURL: 'http://localhost:5000/api/auth'
})

export const registerUser = (data: { name: string; email: string; password: string }) =>
  API.post('/register', data)

export const loginUser = (data: { email: string; password: string }) =>
  API.post('/login', data)