# Use the official Flutter Docker image
FROM cirrusci/flutter:2.8.1 AS builder

# Set environment variables
ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run basic commands to fetch Flutter dependencies
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Set working directory
WORKDIR /app

# Copy pubspec.yaml and pubspec.lock files to the working directory
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN flutter pub get

# Copy the entire project to the working directory
COPY . .

# Build the Flutter app for the web
RUN flutter build web --release

# Stage 2: Serve the built app using nginx
FROM nginx:alpine

# Copy the built app from the previous stage to the nginx html directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
