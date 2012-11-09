#!/bin/sh

set -e

# Must be a valid filename
NAME=trinidad
#/var/run/app must be writable by your user
FILE_ROOT=`dirname $(readlink -f $0)`
APP_DIR="$FILE_ROOT/.."
PIDFILE=$APP_DIR/tmp/pids/trinidad.pid
#This is the command to be run, give the full pathname
DAEMON="/usr/bin/trinidad"
#create a config yml with daemonization options in it - and the same PIDFILE path as above
DAEMON_OPTS="--config=$APP_DIR/config/trinidad.yml"
USER=fatfreecrm

# below is our java opts, for a 8 gig ram, xeon quadcore machine, you might want to change this
export JAVA_OPTS="-server -Xmx2500m -Xms2500m -XX:PermSize=512m -XX:MaxPermSize=512m -XX:NewRatio=2 -XX:+DisableExplicitGC -Dhk2.file.directory.changeIntervalTimer=6000 -Xss2048k -XX:ParallelGCThreads=4 -XX:+AggressiveHeap"

export PATH="${PATH:+$PATH:}/usr/sbin:/sbin"

case "$1" in
  start)
        echo -n "Starting daemon: "$NAME
  start-stop-daemon --start --chdir $APPDIR --quiet --chuid $USER --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_OPTS
        echo "."
  ;;
  stop)
        echo -n "Stopping daemon: "$NAME
  start-stop-daemon --stop --chdir $APPDIR --quiet --chuid $USER --oknodo --pidfile $PIDFILE
        echo "."
  ;;
  restart)
        echo -n "Restarting daemon: "$NAME
  start-stop-daemon --stop --chdir $APPDIR --quiet --chuid $USER --oknodo --retry 30 --pidfile $PIDFILE
  start-stop-daemon --start --chdir $APPDIR --quiet --chuid $USER --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_OPTS
  echo "."
  ;;

  *)
  echo "Usage: "$1" {start|stop|restart}"
  exit 1
esac

exit 0
