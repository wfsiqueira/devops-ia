ARG JAVA_RUNTIME_IMAGE=dhi.io/eclipse-temurin:21-alpine3.23

FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app
RUN javac -version && mvn -version
COPY pom.xml ./
RUN mvn dependency:resolve
COPY src/ ./src/
RUN mvn -DskipTests package -q

FROM busybox:1.37.0-musl AS healthcheck

FROM ${JAVA_RUNTIME_IMAGE} AS runtime

WORKDIR /app
COPY --from=build --chown=10001:10001 /app/target/lab03-api-0.0.1-SNAPSHOT.jar /app/app.jar
COPY --from=healthcheck --chown=10001:10001 /bin/busybox /usr/bin/wget
USER 10001
EXPOSE 8080
HEALTHCHECK CMD ["wget", "-qO-", "http://localhost:8080/actuator/health"]
ENTRYPOINT ["java", "-jar", "app.jar"]
