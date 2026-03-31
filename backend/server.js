const express = require('express')
const cors = require('cors')
require('dotenv').config()

const connectDB = require('./config/db')
const userRoutes = require('./routes/UserRoutes')

const app = express()

// Middleware
app.use(cors())
app.use(express.json())

// Routes
app.use('/api/auth', userRoutes)

// Health check — Kubernetes will use this later!
app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})

// Connect DB then start server
connectDB().then(() => {
  app.listen(process.env.PORT, () => {
    console.log(`🚀 Server running on port ${process.env.PORT}`)
  })
})