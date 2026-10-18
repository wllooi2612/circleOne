FROM node:20-slim

WORKDIR /app

# Copy dependency specifications from backend
COPY backend/package*.json ./

# Install production dependencies
RUN npm install --production

# Copy backend source code
COPY backend/ ./

# Create symlink so commands like `cd backend && ...` succeed seamlessly
RUN ln -s /app /app/backend

# Run server
CMD ["node", "server.js"]

