# Container image that runs your code
FROM alpine:3.10

# Note: Latest version of kubectl may be found at:
# https://github.com/kubernetes/kubernetes/releases
ENV KUBE_LATEST_VERSION="v1.16.2"
# Note: Latest version of helm may be found at:
# https://github.com/kubernetes/helm/releases
ENV HELM_VERSION="v3.4.2"
ENV AZURE_CLI_VERSION 2.0.81

# General deps
RUN apk update && \
    apk upgrade && \
    apk add --no-cache ca-certificates bash git openssh curl python3 python2 py2-pip

# Kubectl
RUN wget -q https://storage.googleapis.com/kubernetes-release/release/${KUBE_LATEST_VERSION}/bin/linux/amd64/kubectl -O /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
# Helm
RUN wget -q https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz -O - | tar -xzO linux-amd64/helm > /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm

# aws-iam-authenticator  

RUN curl -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator && \
    chmod +x /usr/local/bin/aws-iam-authenticator

# awscli
RUN pip3 install awscli

# azure-cli
RUN apk add --no-cache curl tar openssl sudo bash jq
RUN apk --update --no-cache add postgresql-client postgresql
RUN apk add py-pip && \
    apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make
RUN pip --no-cache-dir install azure-cli==${AZURE_CLI_VERSION}

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY entrypoint.sh /entrypoint.sh

# Code file to execute when the docker container starts up (`entrypoint.sh`)
ENTRYPOINT ["/entrypoint.sh"]
