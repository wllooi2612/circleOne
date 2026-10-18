FROM node:20-slim

WORKDIR /app

# Copy dependency specifications from backend
COPY backend/package*.json ./

# Install production dependencies
RUN npm install --production

# Copy backend source code
COPY backend/ ./

ENV PORT=3000
EXPOSE 3000

CMD ["node", "server.js"]
