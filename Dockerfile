# ---- Step 1: Build the Spring Boot Application ----
FROM maven:3.9.5-eclipse-temurin-17 AS builder
WORKDIR /app

# Copy Maven project files & install dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy source code and build the application
COPY src/ src/
RUN mvn package -DskipTests

# ---- Step 2: Create Final Lightweight Image ----
FROM openjdk:17-jdk-alpine
WORKDIR /app

# Install curl in the final image
RUN apk --no-cache add curl

# Expose port 8080
EXPOSE 8080

# Copy only the built JAR from the builder stage
COPY --from=builder /app/target/springboot-aws-deploy-service.jar /app/app.jar

# Run the Spring Boot application
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app/app.jar"]