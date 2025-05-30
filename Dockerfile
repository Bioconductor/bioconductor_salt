ARG BASE_IMAGE=ubuntu:noble
FROM ${BASE_IMAGE} AS build
ARG CYCLE=release
ARG NAME=
RUN useradd -ms /bin/bash biocbuild && apt update -qq && apt install sudo systemd -y && usermod -aG sudo biocbuild && echo "biocbuild ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER biocbuild
COPY . /home/biocbuild/bioconductor_salt
WORKDIR /home/biocbuild
RUN DEBIAN_FRONTEND="noninteractive" bash bioconductor_salt/startup_bbs_standalone_${CYCLE}.sh ${NAME}

FROM ${BASE_IMAGE} AS final
COPY --from=build / /
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/bbs_r_start"]

