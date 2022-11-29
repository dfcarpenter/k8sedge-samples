FROM debian:bullseye-slim 

LABEL org.opencontainers.image.source = https://github.com/dfcarpenter/k8s-samples
LABEL org.opencontainers.image.description = "container image for opc robotics monitoring app"

RUN apt-get update