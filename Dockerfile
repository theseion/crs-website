FROM mcr.microsoft.com/devcontainers/base:debian@sha256:cd98f76771f949a9ffd714663d42a498b45e1a6493bc1d563cffa523d43d9bdb as build

# VARIANT can be either 'hugo' for the standard version or 'hugo_extended' for the extended version.
ARG VARIANT=hugo_extended
# VERSION can be either 'latest' or a specific version number
ARG HUGO_VERSION=latest
ARG SASS_VERSION=latest

RUN apt-get install ca-certificates jq

RUN URL=$(curl -s https://api.github.com/repos/gohugoio/hugo/releases/${HUGO_VERSION} | jq -r ".assets[] | select(.name | test(\"${VARIANT}.*Linux-64bit.tar.gz\")) | .browser_download_url") && \
    wget -O ${HUGO_VERSION}.tar.gz "${URL}" && \
    tar xf ${HUGO_VERSION}.tar.gz && \
    mv hugo* /usr/bin/hugo

RUN URL=$(curl -s https://api.github.com/repos/sass/dart-sass/releases/${SASS_VERSION} | jq -r ".assets[] | select(.name | test(\".*linux-x64-musl.tar.gz\")) | .browser_download_url") && \
    wget -O ${SASS_VERSION}.tar.gz "${URL}" && \
    tar xf ${SASS_VERSION}.tar.gz && \
    mv dart-sass/sass /usr/bin/sass

FROM mcr.microsoft.com/devcontainers/javascript-node@sha256:f1e8fdca29c437891d8d793bf59d368e4c1850884c22161f7401086da63332d4
COPY --from=build /usr/bin/hugo /usr/bin
COPY --from=build /usr/bin/sass /usr/bin
EXPOSE 1313
WORKDIR /src
CMD ["/usr/bin/hugo server"]
