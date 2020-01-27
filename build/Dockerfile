#
#                    ##        .            
#              ## ## ##       ==            
#           ## ## ## ##      ===            
#       /""""""""""""""""\___/ ===        
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~   
#       \______ o          __/            
#         \    \        __/             
#          \____\______/                
# 
#          |          |
#       __ |  __   __ | _  __   _
#      /  \| /  \ /   |/  / _\ | 
#      \__/| \__/ \__ |\_ \__  |
#
# Dockerfile for remote docker controller

ARG DOCKER_IMAGE="docker:latest"
ARG ALPINE_IMAGE="alpine:latest"
ARG COMPOSE_VERSION="1.25.3"

FROM ${DOCKER_IMAGE} AS docker
#########################################
FROM ${ALPINE_IMAGE}

MAINTAINER Uni Mock <unimock@gate-m.de>

RUN apk update && \
    apk add bash openssh rsync git clamav-daemon clamav-libunrar && \
    mkdir -p ~root/.ssh && chmod 700 ~root/.ssh/ && \
    sed -i -e 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    cp -a /etc/ssh /etc/ssh.cache

RUN apk add rsnapshot tzdata curl
COPY ./rsnapshot.conf /etc/rsnapshot.conf-unimock

#RUN apk add py-pip && \
#    pip install --upgrade pip && \ 
#    pip install docker-compose

RUN curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
 chmod a+x /usr/local/bin/docker-compose

RUN rm -rf /var/cache/apk/*

COPY --from=docker /usr/local/bin/docker          /usr/bin/docker

COPY ./bin/* /usr/local/bin/

RUN echo ". /etc/profile" > /root/.bashrc
RUN echo "export PS1='\H:\w\\$ '" >> /etc/profile
RUN echo "alias ll='ls -alF'"     >> /etc/profile
RUN echo 'export TERM="xterm"'    >> /etc/profile

RUN cp -f /usr/share/zoneinfo/Europe/Berlin /etc/localtime
RUN passwd -u root

COPY ./entry.sh /entry.sh

EXPOSE 22


ENTRYPOINT ["/entry.sh"]

CMD ["/usr/sbin/sshd", "-D", "-f", "/etc/ssh/sshd_config"]
