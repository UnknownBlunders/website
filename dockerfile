FROM ubuntu:24.04 AS build

RUN apt update && apt install hugo -y
COPY . .
RUN hugo

FROM ghcr.io/nginx/nginx-unprivileged:1.29.3-alpine-perl

LABEL org.opencontianers.image.authors="ethan norlander" 

COPY --from=build /public/ /usr/share/nginx/html
