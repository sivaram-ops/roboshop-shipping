# stage 1
FROM maven:3.9.5-amazoncorretto-17 AS build 
WORKDIR /shipping
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src
RUN mvn clean package -DskipTests
# stage 2
FROM amazoncorretto:25
EXPOSE 8080
WORKDIR /shipping
ENV CART_ENDPOINT=cart:8080
COPY --from=build /shipping/target/shipping-1.0.jar shipping.jar
CMD [ "java", "-XX:+ExitOnOutOfMemoryError", "-XX:MaxRAMPercentage=80.0", "-jar", "shipping.jar" ]

# Environment=CART_ENDPOINT=cart:8080
# Environment=DB_HOST=mysql
# Environment=DBHOST=mysql