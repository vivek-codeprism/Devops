FROM jenkins/jenkins:lts
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
RUN install-plugins.sh github-branch-source workflow-aggregator
USER root
RUN apt-get update && apt-get install -y apt-transport-https
ADD https://storage.googleapis.com/kubernetes-release/release/v1.10.11/bin/linux/amd64/kubectl /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl
RUN curl -sSL https://get.docker.com/ | sh
RUN usermod -aG docker jenkins
USER jenkins
