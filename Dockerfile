# Stage 1: Build the Flutter web application
FROM ghcr.io/cirrusci/flutter:stable AS builder

WORKDIR /app

# Copy configuration files
COPY pubspec.yaml pubspec.lock ./

# Fetch dependencies
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build the web application
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Serve the application using NGINX
FROM nginx:alpine

# Copy build artifacts to NGINX html directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom entrypoint script to handle runtime environment variables
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
