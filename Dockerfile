FROM node:20-slim

WORKDIR /app

# Copy dependency specifications from backend
COPY backend/package*.json ./

# Install production dependencies
RUN npm install --production

# Copy backend source code
COPY backend/ ./

# Do not hardcode PORT so Railway's dynamic PORT environment variable is used
CMD ["node", "server.js"]
