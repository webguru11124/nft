# Stage 1: Build the Nest.js application
FROM node:24-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml for dependency installation
COPY package.json pnpm-lock.yaml ./

# Install dependencies
RUN pnpm install

# Copy the rest of the application source code
COPY . .

# Build the application
RUN pnpm build

# Stage 2: Run the application with a minimal image
FROM node:24-alpine AS runner

# Install pnpm again for the runtime stage
RUN corepack enable && corepack prepare pnpm@latest --activate

# Set environment variables
ENV NODE_ENV=production

# Set the working directory inside the container
WORKDIR /app

# Copy package.json for production dependencies
COPY package.json ./

# Install only production dependencies
RUN pnpm install --only=production

# Copy built application from the build stage
COPY --from=builder /app/dist ./dist

# Expose the application port (usually 3000 by default in Nest.js)
EXPOSE 3000

# Set the default command to run the application
CMD ["node", "dist/main"]
