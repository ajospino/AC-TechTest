FROM alpine:latest

RUN apk add apache2 \
        openjdk17 \
        maven \
        postgresql \
        dotnet7-sdk

RUN rc-service apache2 start