# ------------ Stage 1: Build the Spring Boot app ------------

# base image that has Maven and Java 17 installed  and AS build gives this stage a name ("build") so it can be referenced later (like in COPY --from=build).

FROM maven:3.9.11-ibm-semeru-21-noble AS build

#Current working directory inside containers

WORKDIR app/

#📄 Copies pom.xml from local project directory into Docker container's app/ directory.This is done first so Docker can cache Maven dependencies during repeated builds.

COPY pom.xml .

#Copy entire src/ foldercode from local(host machine) to current working directory of into the container (app/src)

COPY src ./src

# Runs Maven inside the container to compile the code and package it into a .jar:,clean: removes previous builds,package: compiles and packages the app,-DskipTests: skips running unit tests (for faster builds)

# At the end of this stage, the built .jar file is located at:/app/target/*.jar

RUN  mvn clean package -DskipTests


# ------------ Stage 2: Create the final image ------------
#Uses a lightweight Java 17 runtime image (Temurin is the official OpenJDK distribution by Eclipse).This final image does not include Maven, keeping it small and secure.

FROM eclipse-temurin:17-jdk

#Sets the working directory in this new runtime image.

WORKDIR /app

# Copies the built .jar file from the first stage (build) into this second image, and renames it to app.jar.
COPY --from=build /app/target/*.jar app.jar

#container will listen on port 8080

EXPOSE 8080

#Defines the command that will be executed when the container starts — it launches your Spring Boot app.

ENTRYPOINT ["java", "-jar", "app.jar"]
