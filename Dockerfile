# syntax=docker/dockerfile:1
FROM debian:bookworm-slim AS build
# Refresh image and install dependencies
RUN apt-get update
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install ca-certificates curl apt-transport-https lsb-release gnupg wget nodejs -y
RUN echo "deb http://deb.debian.org/debian $(lsb_release -cs)-backports main" > /etc/apt/sources.list.d/backport-bullseye.list
RUN apt-get update
# Add hashicorp mirror
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list
# Add microsoft mirror
RUN mkdir -p /etc/apt/keyrings/
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
RUN AZ_DIST=$(lsb_release -cs); echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" > /etc/apt/sources.list.d/azure-cli.list
# Install terraform azurerm naming
RUN apt search "golang-1.*-go"
RUN apt-get install -y golang-1.21-go
RUN update-alternatives --install /usr/bin/go go /usr/lib/go-1.21/bin/go 10
RUN go install github.com/terraform-linters/tflint@v0.50.3
RUN go install github.com/aquasecurity/tfsec/cmd/tfsec@latest

RUN go clean -cache
RUN go clean -modcache
RUN apt-get autoremove -y golang-1.21-go

# Refresh package list and install
RUN apt-get update
RUN apt-get install -y azure-cli
RUN apt-get install -y terraform
RUN apt-get install -y python3-yaml
RUN apt-get clean all

# Shrink image by copying files
FROM scratch
COPY --from=build / /
ENTRYPOINT ["/bin/bash"]
