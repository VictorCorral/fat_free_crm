#!/usr/bin/env bash

set -e

RAILS_ENV_DEFAULT=production
RAILS_PORT_DEFAULT=4000
RAILS_STDOUT_LOG_DEFAULT=/dev/null
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RAILS_PIDFILE_DEFAULT=$DIR/../tmp/pids/trinidad.pid

usage()
{
cat <<EOF
  usage: $0 [ARGS] start|stop|restart

  args:
    [-e development|production|test|postgres_test (default: $RAILS_ENV_DEFAULT)]
    [-p PORT_NUMBER (default: $RAILS_PORT_DEFAULT)]
    [-f PIDFILE (default: $RAILS_PIDFILE_DEFAULT)]
    [-l STDOUT_LOG (default: $RAILS_STDOUT_LOG_DEFAULT)]
EOF
}

start()
{
  if [ -e $RAILS_PIDFILE ]; then
    echo "Error: pid file $RAILS_PIDFILE exists."
    return 1
  else
    echo "Starting tomcat/rails in $RAILS_ENV mode..."
    pushd "$DIR/.." > /dev/null
        jruby --1.9 --server -J-Djruby.compile.mode=FORCE -J-Dcom.sun.management.jmxremote.port=2400 -J-Dcom.sun.management.jmxremote  -J-Dcom.sun.management.jmxremote.authenticate=false  -J-Dcom.sun.management.jmxremote.ssl=false -J-Xmn128m -J-Xms512m -J-Xmx2048m -J-XX:MaxPermSize=512m -S trinidad --threadsafe --config -p ${RAILS_PORT} -e ${RAILS_ENV} &> ${RAILS_STDOUT_LOG} &
    popd > /dev/null
    echo $! > $RAILS_PIDFILE
    echo "...success."
    echo "Logging stdout to $RAILS_STDOUT_LOG"
    return 0
  fi
}

stop()
{
  if [ -e $RAILS_PIDFILE ]; then
    pid=`cat $RAILS_PIDFILE`
    echo "Trying to kill $pid..."
    if kill $pid &> /dev/null; then
      echo " success."
      rm -f $RAILS_PIDFILE
      return 0
    else
      echo " error killing $pid (from file $RAILS_PIDFILE)... aborting."
      return 3
    fi
  else
    echo "File $RAILS_PIDFILE doesn't exist... nothing to do."
    return 0
  fi
}

restart()
{
  stop
  if [ $? == 0 ]; then
    start
  fi
}

while getopts "e:f:l:h" FLAG; do
  case $FLAG in
    e) RAILS_ENV=$OPTARG;;
    p) RAILS_PORT=$OPTARG;;
    f) RAILS_PIDFILE=$OPTARG;;
    l) RAILS_STDOUT_LOG=$OPTARG;;
    h) usage; exit 0;;
  esac
done
shift $((OPTIND-1))

: ${RAILS_ENV=$RAILS_ENV_DEFAULT}
: ${RAILS_PORT=$RAILS_PORT_DEFAULT}
: ${RAILS_PIDFILE=$RAILS_PIDFILE_DEFAULT}
: ${RAILS_STDOUT_LOG=$RAILS_STDOUT_LOG_DEFAULT}

RETVAL=3
if [ "x$@" == "xstart" ]; then
  start
  RETVAL=$?
elif [ "x$@" == "xstop" ]; then
  stop
  RETVAL=$?
elif [ "x$@" == "xrestart" ]; then
  restart
  RETVAL=$?
else
  usage
fi

exit $RETVAL

