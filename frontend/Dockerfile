FROM debian:latest AS build-env

RUN apt-get update
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 xz-utils
RUN apt-get clean

RUN wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_2.10.2-stable.tar.xz && \
    tar xf flutter_linux_2.10.2-stable.tar.xz

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

WORKDIR APP
COPY . .
RUN flutter build web

FROM nginx:1.21.1-alpine
COPY --from=build-env /APP/build/web /usr/share/nginx/html
