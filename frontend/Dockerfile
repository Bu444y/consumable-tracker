# Build stage
FROM node:18-alpine as build

# Add DNS resolution fix
RUN echo 'hosts: files dns' >> /etc/nsswitch.conf

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with retry logic
RUN npm config set registry https://registry.npmjs.org/ && \
    npm cache clean --force && \
    npm install --legacy-peer-deps --verbose || \
    (sleep 5 && npm install --legacy-peer-deps --verbose) || \
    (sleep 10 && npm install --legacy-peer-deps --verbose)

# Copy source and build
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
