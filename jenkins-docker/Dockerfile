FROM jenkins/jenkins:lts
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt update -y && \
    apt install -y jq parallel gnupg software-properties-common wget openssl && \
    curl -sSL https://get.docker.com/ | sh

# Install Terraform and AZ Cli
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform && \
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

#Install kubernetes and Helm
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

# Install Ruby and WPScan
RUN apt-get install -y ruby-full build-essential ruby-dev && \
    gem install wpscan

# Install Certbot and Certbot plugin for Gandi
RUN apt update && \
    apt install -y certbot python3-pip && \
    pip3 install certbot-plugin-gandi

# Switch back to the jenkins user
USER jenkins