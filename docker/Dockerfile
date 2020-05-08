ARG FEDORA_VERSION=32
FROM fedora:$FEDORA_VERSION

LABEL maintainer="Miguel Pereira"
LABEL source="https://github.com/onemorepereira/fedora_workstation_builder"

COPY temp_key.pub /root/.ssh/authorized_keys
EXPOSE 22
RUN useradd test
RUN dnf -y install openssh-server passwd && dnf clean all
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 

CMD ["/usr/sbin/sshd", "-D", "-e"]
