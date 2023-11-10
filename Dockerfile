FROM ubuntu:jammy
ARG CYCLE=release
RUN useradd -ms /bin/bash biocbuild && apt update -qq && apt install sudo systemd -y && usermod -aG sudo biocbuild && echo "biocbuild ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER biocbuild
COPY . /home/biocbuild/bioconductor_salt
WORKDIR /home/biocbuild
RUN bash bioconductor_salt/startup_bbs_standalone_${CYCLE}.sh
ENTRYPOINT ["/bbs_r_start"]
