FROM ubuntu:jammy
RUN useradd -ms /bin/bash biocbuild && apt update -qq && apt install sudo systemd -y && usermod -aG sudo biocbuild && echo "biocbuild ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER biocbuild
COPY . /home/biocbuild/bioconductor_salt
WORKDIR /home/biocbuild
RUN bash bioconductor_salt/simple_start_linux.sh
CMD ["/bbs_r_start"]

