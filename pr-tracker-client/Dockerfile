# ── Stage 1: Builder ─────────────────────────────────────────────
FROM node:20-alpine AS builder
LABEL stage=builder

# Accept VITE_SERVER_ENDPOINT as a build arg so Docker Compose / CI can pass it in.
# Vite bakes env vars at build time — this is the correct injection point.
ARG VITE_SERVER_ENDPOINT=http://localhost
ENV VITE_SERVER_ENDPOINT=${VITE_SERVER_ENDPOINT}

WORKDIR /app

# Install deps first (layer-cached unless package*.json changes)
COPY package*.json ./
RUN npm ci --ignore-scripts

COPY . .
RUN npm run build
# Output: /app/dist — static HTML/CSS/JS with env var baked in

# ── Stage 2: Production (Nginx) ───────────────────────────────────
FROM nginx:1.27-alpine AS production

# Remove default Nginx config
RUN rm -f /etc/nginx/conf.d/default.conf

# Copy Vite build output
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy our Nginx configs
COPY nginx/nginx.conf          /etc/nginx/conf.d/default.conf
COPY nginx/security-headers.conf /etc/nginx/security-headers.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget --spider -q http://localhost/healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
