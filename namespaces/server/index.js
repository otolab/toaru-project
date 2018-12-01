const http = require('http')
const express = require('express')
const path = require("path")

const server = http.createServer()

const PORT = process.env.PORT || 8000

app = express()

app.use(express.static(path.join(__dirname, "../public")))

app.get('/', (req, res, next) => {
  res.send('<html><head><script async src="/js/index.js"></script></head><body><article class="content"></article></body></html>')
})

app.server = http.createServer(app)

app.server.listen(PORT, '0.0.0.0', () => {
  console.log('listen start')
})
