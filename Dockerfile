# Set default values for build arguments
ARG DOCKERFILE_VERSION=1.1.0
ARG NETCORE_VERSION=3.1

# Extend Alpine variant of ASP.net base image for small image size
FROM mcr.microsoft.com/dotnet/core/aspnet:${NETCORE_VERSION} AS production

ARG DOCKERFILE_VERSION
ARG NETCORE_VERSION

# Default the runtime image to run as production
ENV ASPNETCORE_ENVIRONMENT=production

# Create a dotnet user to run as
RUN addgroup -g 1000 dotnet \
    && adduser -u 1000 -G dotnet -s /bin/sh -D dotnet

# Default to the dotnet user and run from their home folder
USER dotnet
WORKDIR /home/dotnet

# Label images to aid searching
LABEL uk.gov.defra.dotnetcore.dotnet-version=$NETCORE_VERSION \
      uk.gov.defra.dotnetcore.version=$DOCKERFILE_VERSION \
      uk.gov.defra.dotnetcore.repository=defradigital/dotnetcore

# Extend Alpine variant of .Net Core SDK base image for small image size
FROM mcr.microsoft.com/dotnet/core/sdk:${NETCORE_VERSION} AS development

ARG DOCKERFILE_VERSION
ARG NETCORE_VERSION

# Default the SDK image to run as development
ENV ASPNETCORE_ENVIRONMENT=development

LABEL uk.gov.defra.dotnetcore.dotnet-version=$NETCORE_VERSION \
      uk.gov.defra.dotnetcore.version=$DOCKERFILE_VERSION \
      uk.gov.defra.dotnetcore.repository=defradigital/dotnetcore-development

# Create a dotnet user to run as
RUN addgroup -g 1000 dotnet \
    && adduser -u 1000 -G dotnet -s /bin/sh -D dotnet

# Install dev tools, such as remote debugger and its dependencies
RUN apk update \
  && apk --no-cache add curl procps unzip \
  && wget -qO- https://aka.ms/getvsdbgsh | /bin/sh /dev/stdin -v latest -l /vsdbg
# Pact dependencies are not included in Alpine image for contract testing
RUN  apk --no-cache add ca-certificates wget bash \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk \
    && apk add glibc-2.29-r0.apk

# Default to the dotnet user and run from their home folder
USER dotnet
WORKDIR /home/dotnet
