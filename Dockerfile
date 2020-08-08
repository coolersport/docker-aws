FROM alpine/helm:2.16.3 AS helm

# copied from google/cloud-sdk with latest alpine and sdk versions
FROM amazon/aws-cli:2.0.38

COPY --from=helm /usr/bin/helm /usr/local/bin/helm
COPY ./entrypoint.sh /

RUN yum update && yum upgrade -y && \
    yum install -y \
        shadow-utils \
        unzip && \
# add non-privileged user
    useradd aws && \
    chmod 777 /home/aws && \
# install rclone
    cd /tmp && \
    curl -fsSL https://downloads.rclone.org/rclone-current-linux-amd64.zip -o rclone.zip && \
    unzip rclone.zip && \
    mv rclone-v*/rclone* /usr/local/bin && \
    rm -rf rclone* && \
# install kubectl
    kubectlversion=1.15.11 && \
    cd /usr/local/bin && \
    curl -fsSL https://storage.googleapis.com/kubernetes-release/release/v${kubectlversion}/bin/linux/amd64/kubectl -o kubectl-${kubectlversion} && \
    chmod +x kubectl-${kubectlversion} && \
    ln -s kubectl-${kubectlversion} kubectl && \
# install gosu
    curl -fsSL "https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64" -o /usr/bin/gosu && \
    chmod +x /usr/bin/gosu && \
    gosu nobody true && \
# cleanup
    chmod +x /entrypoint.sh && \
    yum remove -y shadow-utils unzip && \
    yum clean all && rm -rf /var/cache/yum

ENV HOME /home/aws
USER aws
WORKDIR /home/aws

ENTRYPOINT ["/entrypoint.sh"]
