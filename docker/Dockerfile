ARG FEDORA_VERSION=44
FROM fedora:${FEDORA_VERSION}

LABEL maintainer="Miguel Pereira"
LABEL source="https://github.com/onemorepereira/fedora_workstation_builder"

RUN dnf -y install openssh-server passwd python3-libdnf5 && dnf clean all
RUN ssh-keygen -A

COPY temp_key.pub /root/.ssh/authorized_keys
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]
