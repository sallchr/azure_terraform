# syntax=docker/dockerfile:1
FROM debian:bullseye-slim
# Refresh image and install dependencies
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get install ca-certificates curl apt-transport-https lsb-release gnupg -y
# Add hashicorp mirror
RUN wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
# Add microsoft mirror
RUN curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg
RUN AZ_DIST=$(lsb_release -cs); echo "deb [arch=`dpkg --print-architecture` signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $AZ_DIST main" > /etc/apt/sources.list.d/azure-cli.list
# Refresh package list and install
RUN apt-get update
RUN apt-get install -y azure-cli
RUN apt-get install -y terraform
RUN apt-get clean all
ENTRYPOINT ["/bin/bash"]
