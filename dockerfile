FROM ubuntu:22.04 AS build

RUN apt update && apt install hugo -y
COPY . .
RUN hugo

FROM nginx:1.25
LABEL org.opencontianers.image.authors="ethan norlander" 

COPY --from=build /public/ /usr/share/nginx/html