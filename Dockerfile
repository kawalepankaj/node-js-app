FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

FROM node:18-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app .
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "const http=require('http'); const req=http.get('http://127.0.0.1:3000/health', res=>process.exit(res.statusCode===200?0:1)); req.on('error',()=>process.exit(1));"
CMD ["node", "app.js"]