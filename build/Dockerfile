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
FROM alpine:latest

MAINTAINER Uni Mock <unimock@gate-m.de>

RUN apk update && \
    apk add bash git openssh rsync  && \
    mkdir -p ~root/.ssh && chmod 700 ~root/.ssh/ && \
    sed -i -e 's/#Port 22/Port 22/' /etc/ssh/sshd_config && \
    sed -i -e 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    cp -a /etc/ssh /etc/ssh.cache

RUN apk add rsnapshot
COPY ./rsnapshot.conf /etc/rsnapshot.conf-unimock

RUN apk add curl docker && \
    cp -a /usr/bin/docker /tmp && \
    apk del docker && \
    mv /tmp/docker /usr/bin/ 

RUN apk add py2-pip && \
    pip install --upgrade pip && \ 
    pip install docker-compose

RUN rm -rf /var/cache/apk/*

COPY ./bin/ovw /usr/local/bin/ovw
COPY ./bin/rdc /usr/local/bin/rdc
RUN chmod a+x /usr/local/bin/*

RUN echo ". /etc/profile" > /root/.bashrc
RUN echo "export PS1='\H:\w\\$ '" >> /etc/profile
RUN echo "alias ll='ls -alF'"     >> /etc/profile
RUN echo 'export TERM="xterm"'    >> /etc/profile

COPY ./entry.sh /entry.sh

EXPOSE 22


ENTRYPOINT ["/entry.sh"]

CMD ["/usr/sbin/sshd", "-D", "-f", "/etc/ssh/sshd_config"]