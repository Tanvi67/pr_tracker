# Stage 1: Build environment
FROM node:20-alpine AS builder
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci
COPY . .

# Stage 2: Production dependencies
FROM node:20-alpine AS deps
WORKDIR /usr/src/app
COPY package*.json ./
RUN npm ci --omit=dev

# Stage 3: Final Production Image
FROM node:20-alpine AS runner
WORKDIR /usr/src/app
ENV NODE_ENV=production

# Copy node_modules from deps stage
COPY --from=deps /usr/src/app/node_modules ./node_modules
# Copy application code from builder stage
COPY --from=builder /usr/src/app ./

EXPOSE 5004
CMD ["npm", "start"]
