ARG IMAGE_ARCH
ARG IMAGE_DISTRO
ARG IMAGE_VERSION
FROM ${IMAGE_ARCH}/${IMAGE_DISTRO}:${IMAGE_VERSION}

ARG QEMU_FILE
ADD ${QEMU_FILE} /usr/bin

RUN /debootstrap/debootstrap --second-stage

ARG UPDATE_CMD
RUN ${UPDATE_CMD}

ENV DEBIAN_FRONTEND noninteractive
ARG INSTALL_CMD
RUN ${INSTALL_CMD}

ARG CLEANUP_CMD
RUN ${CLEANUP_CMD}

ARG RUN_CMD
ENV RUN_CMD ${RUN_CMD}
CMD ${RUN_CMD}