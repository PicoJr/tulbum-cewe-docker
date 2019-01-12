FROM ubuntu:18.04
MAINTAINER rusodavid@gmail.com
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get dist-upgrade
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-x-swat/updates
RUN apt-get -y dist-upgrade
RUN apt-get install -y build-essential
RUN apt-get install -y unzip
RUN apt-get install -y less
RUN apt-get install -y wget
RUN apt-get install -y libgtk-3-0
RUN apt-get install -y libcanberra-gtk3-module
RUN apt-get install -y libgl1-mesa-dri 
RUN apt-get install -y libgl1-mesa-glx 
RUN cpan 
RUN cpan File::Copy
RUN apt-get install -y locales
RUN apt-get -y update
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
#ENV LC_ALL en_US.UTF-8
RUN locale-gen en_US en_US.UTF-8
RUN dpkg-reconfigure locales
RUN apt-get install -y xdg*

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
RUN sh -c '/bin/echo -ne “\\sí\\\” | perl install.pl'


ENTRYPOINT ["/home/tualbum/CEWE/Taller CEWE/Taller CEWE"]
