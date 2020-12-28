FROM python:3.9-slim
ARG ANSIBLE_VERSION="2.10.4"
COPY ./entrypoint.sh /usr/local/bin
RUN set -exo ;\
    apt-get update -y ;\
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        sshpass dumb-init openssh-client ca-certificates wget ;\
    # Install su-exec
    wget https://launchpad.net/~hnakamur/+archive/ubuntu/su-exec/+build/16698605/+files/su-exec_0.2-1ppa1~ubuntu18.04_amd64.deb ;\
    dpkg -i su-exec_0.2-1ppa1~ubuntu18.04_amd64.deb ;\
    rm su-exec_0.2-1ppa1~ubuntu18.04_amd64.deb ;\
    # Install ansible
    pip3 install --no-cache --upgrade ansible==${ANSIBLE_VERSION} ;\
    # Install dependency for hashi_vault lookup plugin https://docs.ansible.com/ansible/latest/collections/community/general/hashi_vault_lookup.html#requirements
    pip3 install --no-cache --upgrade hvac ;\
    # Default for ansible inventory and prepared user 'ansible'
    mkdir -p /etc/ansible/ ;\
    /bin/echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts ;\
    adduser --shell /bin/bash --uid 1000 --disabled-password --home /ansible ansible ;\
    # Make entrypoint executable
    chmod +x /usr/local/bin/entrypoint.sh ;\
    # Cleaning unnecessary packages
    apt purge -y --allow-remove-essential wget fdisk e2fsprogs mount findutils util-linux sysvinit-utils bash bsdutils ;\
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /ansible
# ENTRYPOINT is used when you start container with some arguments. Es 'docker run md/ansible myargument'
ENTRYPOINT ["/usr/bin/dumb-init","--","entrypoint.sh"]
# CMD is used when you start container with without arguments. Es 'docker run md/ansible'
CMD ["/bin/sh"]

