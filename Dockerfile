FROM ubuntu:18.04
MAINTAINER rusodavid@gmail.com
ENV DEBIAN_FRONTEND noninteractive

# RUN apt-get dist-upgrade
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository ppa:ubuntu-x-swat/updates \
    && apt-get -y dist-upgrade \
    && apt-get install -y build-essential \
    && apt-get install -y unzip \
    && apt-get install -y less \
    && apt-get install -y wget \
    && apt-get install -y libgtk-3-0 \
    && apt-get install -y libcanberra-gtk3-module \
    && apt-get install -y libgl1-mesa-dri  \
    && apt-get install -y libgl1-mesa-glx  \
    && apt-get install -y libnss3 \
    && cpan  \
    && cpan File::Copy \
    && apt-get install -y locales \
    && apt-get -y update

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8 \
    && dpkg-reconfigure locales \
    && apt-get install -y xdg*

# Set up the user
ARG UNAME=tualbum
ARG UID=1001
ARG GID=1001
ARG HOME=/home/${UNAME}
RUN mkdir -p ${HOME} && \
    mkdir /${HOME}/tualbum && \
    mkdir /${HOME}/.mcf && \
    echo "${UNAME}:x:${UID}:${GID}:${UNAME} User,,,:${HOME}:/bin/bash" >> /etc/passwd && \
    echo "${UNAME}:x:${UID}:" >> /etc/group && \
    mkdir -p /etc/sudoers.d && \
    echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
    chmod 0440 /etc/sudoers.d/${UNAME} && \
    gpasswd --add ${UNAME} adm

RUN  chown ${UID}:${GID} -R ${HOME}

COPY install.pl /${HOME}
COPY EULA.txt /${HOME}

USER ${UNAME}
WORKDIR $HOME

#RUN perl install.pl
RUN sh -c '/bin/echo -ne "/home/tualbum" | perl install.pl'


ENTRYPOINT ["/home/tualbum/tualbum"]
