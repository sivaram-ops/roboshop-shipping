# Stage 1: Build the application
FROM maven:3.9.6-eclipse-temurin-21-alpine AS builder

WORKDIR /shipping

# Copy only the POM file first to leverage Docker layer caching for dependencies
COPY pom.xml .

# Download dependencies in batch mode (-B) to avoid log spam in CI/CD pipelines
RUN mvn dependency:go-offline -B

# Copy source code and build the application
COPY src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Minimal runtime image
FROM eclipse-temurin:21-jre-alpine

# STANDARD METADATA LABELS
LABEL maintainer="roboshop-devops-team" \
      org.opencontainers.image.title="RoboShop Shipping Service" \
      org.opencontainers.image.description="Handles shipping logistics and integrates with MySQL and Cart" \
      org.opencontainers.image.version="v9"

EXPOSE 8080

# Create a non-root user and group for security
RUN addgroup -S roboshop && adduser -S -G roboshop roboshop

WORKDIR /shipping

# Copy the built artifact from the builder stage and set ownership
COPY --from=builder --chown=roboshop:roboshop /shipping/target/shipping-*.jar shipping.jar

# Enforce running as the non-root user
USER roboshop

# Run the application with optimized JVM memory parameters for containerized environments
CMD [ "java", "-XX:+ExitOnOutOfMemoryError", "-XX:MaxRAMPercentage=80.0", "-jar", "shipping.jar" ]