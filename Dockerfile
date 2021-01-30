FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN \
  echo "**** install tools ****" && \
  apt-get update -qq > /dev/null && \
  apt-get install -qqy \
    jq \
    gettext-base \
    less \
    wget \
    unzip \
    tar \
    > /dev/null && \
  echo "**** install aws cli v2 ****" && \
  wget \
    --quiet \
    --output-document awscliv2.zip \
    "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" && \
  mkdir -p awscliv2 && \
  unzip -qq awscliv2.zip -d awscliv2 && \
  cd awscliv2 && \
  aws/install && \
  rm -rf awscliv2 awscliv2.zip && \
  echo "**** install kubectl ****" && \
  KUBECTL_VERSION=$(wget -qO- "https://storage.googleapis.com/kubernetes-release/release/stable.txt") && \
  wget \
    --quiet \
    --output-document kubectl \
    "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
  install kubectl /usr/local/bin && \
  rm kubectl && \
  echo "**** install eksctl ****" && \
  mkdir -p eksctl && \
  wget \
    --quiet \
    --output-document eksctl.tar.gz \
    "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" && \
  tar \
    --extract \
    --gunzip \
    --file eksctl.tar.gz \
    --directory eksctl && \
  install eksctl/eksctl /usr/local/bin && \
  rm -rf eksctl eksctl.tar.gz && \
  echo "**** install helm ****" && \
  HELM_TARBALL_URL=$(wget -qO- "https://api.github.com/repos/helm/helm/releases/latest" | jq -r .tarball_url) && \
  HELM_VERSION=$(echo "${HELM_TARBALL_URL}" | grep -o '[^/v]*$') && \
  mkdir -p helm && \
  wget \
    --quiet \
    --output-document helm.tar.gz \
    "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" && \
  tar \
    --extract \
    --gunzip \
    --file helm.tar.gz \
    --directory helm && \
  install helm/linux-amd64/helm /usr/local/bin && \
  rm -rf helm helm.tar.gz && \
  echo "**** clean up ****" && \
  apt-get clean -qq && \
  rm -rf /var/lib/apt/lists/*

ARG PUID=1000
ARG PGID=1000

RUN \
  addgroup \
    --gid "${PGID}" app && \
  adduser \
    --gid "${PGID}" \
    --uid "${PUID}" \
    --gecos "" \
    --disabled-password \
    --shell /bin/bash \
    --home /app \
    app

RUN \
  echo trap exit TERM > /etc/profile.d/trapterm.sh && \
  echo 'export PS1="\e[1m\e[31m[\$HOST_IP] \e[34m\u@\h\e[35m \w\e[0m\n$ "' >> /app/.bashrc

ENV  \
  HOST_IP="0.0.0.0" \
  PS1="\e[1m\e[31m[\$HOST_IP] \e[34m\u@\h\e[35m \w\e[0m\n$ "

WORKDIR /app

USER app

CMD ["/bin/bash", "-l"]
