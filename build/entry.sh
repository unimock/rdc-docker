#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

DAEMON=sshd

if [ "$CLAMDSCAN_HOST" != "" ] ; then
  sed -i "s|^LocalSocket |#LocalSocket |g"                 /etc/clamav/clamd.conf
  sed -i "s|^#TCPSocket 3310|TCPSocket $CLAMDSCAN_PORT|g"  /etc/clamav/clamd.conf
  sed -i "s|^#TCPAddr localhost|TCPAddr $CLAMDSCAN_HOST|g" /etc/clamav/clamd.conf
  sed -i "s|^#MaxDirectoryRecursion.*|MaxDirectoryRecursion $CLAMDSCAN_MRECDIR|g" /etc/clamav/clamd.conf
fi

echo "# check and apply for overwrites (ovw) :"
if [ ! -e  /service/ovw ] ; then
  mkdir -p /service/ovw
fi
if [ ! -e  /service/mig ] ; then
  mkdir -p /service/mig
fi
rsync -av /service/ovw/ /




# Copy default config from cache
if [ ! "$(ls -A /etc/ssh)" ]; then
   cp -a /etc/ssh.cache/* /etc/ssh/
fi

# Generate Host keys, if required
if ! ls /etc/ssh/ssh_host_* 1> /dev/null 2>&1; then
    ssh-keygen -A
    mkdir -p /service/ovw/etc/ssh
    cp -a /etc/ssh/ssh_host_rsa_key* /service/ovw/etc/ssh
fi
#
# get authorized_keys and id_rsa from docker secrets
#
if [ -e /run/secrets/authorized_keys ] ; then
  mkdir -p ~/.ssh
  cp -v /run/secrets/authorized_keys  ~/.ssh
fi
if [ -e /run/secrets/id_rsa ] ; then
   mkdir -p ~/.ssh
  cp -v /run/secrets/id_rsa  ~/.ssh
fi


# Fix permissions, if writable
if [ -w ~/.ssh ]; then
    chown root:root ~/.ssh && chmod 700 ~/.ssh/
fi
if [ -w ~/.ssh/authorized_keys ]; then
    chown root:root ~/.ssh/authorized_keys
    chmod 600 ~/.ssh/authorized_keys
fi
if [ -w ~/.ssh/id_rsa ]; then
    chown root:root ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
fi


# Warn if no config
if [ ! -e ~/.ssh/authorized_keys ]; then
  echo "WARNING: No SSH authorized_keys found for root"
fi

#if [ "$TRUSTED_ENVIRONMENT" = "yes" ] ; then
#  FI=/etc/ssh/sshd_config
#  sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/'    $FI
#  sed -i -e 's/#PermitEmptyPasswords no/PermitEmptyPasswords yes/'       $FI
#  sed -i -e 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/'  $FI
#fi

FI=/etc/ssh/ssh_config
sed -i -e 's|# Host \*|Host *\n StrictHostKeyChecking no\n UserKnownHostsFile=/dev/null\n LogLevel ERROR|'  $FI


stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -SIGTERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}

echo "Running $@"
if [ "$(basename $1)" == "$DAEMON" ]; then
    trap stop SIGINT SIGTERM
    $@ &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    exec "$@"
fi
