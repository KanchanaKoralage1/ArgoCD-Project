const express = require('express')
const cors = require('cors')
require('dotenv').config()

const client=require('prom-client')
const connectDB = require('./config/db')
const userRoutes = require('./routes/UserRoutes')

const app = express()

//collect default metrics(cpu, memory, event loop)
const collectDefaultMetrics=client.collectDefaultMetrics
collectDefaultMetrics({ timeout: 5000})

//custom metrics (count total http request)
const httpRequestCounter=new client.Counter({
  name: 'http_requests_total',
  help: 'Total number of Http requests',
  labelNames: ['method', 'route', 'status']
})

//custom metrics (track response time)
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status'],
  buckets: [0.1, 0.3, 0.5, 1, 1.5, 2, 3, 5]
})

//Middleware — runs on every request to record metrics
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer()
  res.on('finish', () => {
    httpRequestCounter.inc({
      method: req.method,
      route: req.path,
      status: res.statusCode
    })
    end({
      method: req.method,
      route: req.path,
      status: res.statusCode
    })
  })
  next()
})

// Middleware
app.use(cors())
app.use(express.json())

// Routes
app.use('/api/auth', userRoutes)

// Health check — Kubernetes will use this later!
app.get('/health', (req, res) => {
  res.json({ status: 'ok' })
})

// Metrics endpoint — Prometheus scrapes this
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', client.register.contentType)
  res.end(await client.register.metrics())
})

// Connect DB then start server
connectDB().then(() => {
  app.listen(process.env.PORT, () => {
    console.log(`🚀 Server running on port ${process.env.PORT}`)
    console.log(`📊 Metrics available at http://localhost:${process.env.PORT}/metrics`)
  })
})