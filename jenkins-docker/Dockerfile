FROM jenkins/jenkins:lts
USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y jq parallel unzip nodejs gnupg software-properties-common wget openssl && \
    apt-get install -y git && \
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

# Install SonarCloud
RUN wget -O /tmp/sonarscanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.0.2311-linux.zip && \
    unzip /tmp/sonarscanner.zip -d /opt && \
    rm /tmp/sonarscanner.zip && \
    ln -s /opt/sonar-scanner-4.6.0.2311-linux/bin/sonar-scanner /usr/bin/sonar-scanner

# Install WP-cli apt-get install -y php8.1-cli && \
RUN apt-get install -y php-cli && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar