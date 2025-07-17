# Use official devcontainer base image (Ubuntu)
FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jre \
    curl \
    groovy \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME so Groovy and others can find it
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash \
    && mv nextflow /usr/local/bin/ \
    && chmod +x /usr/local/bin/nextflow \
    && chown vscode:vscode /usr/local/bin/nextflow

# Verify installation
RUN groovy --version && nextflow -version
