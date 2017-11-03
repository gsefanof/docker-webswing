#!/usr/bin/env bash

# Set variables
if [ -z "${WEBSWING_OPTS}" ]; then
  export WEBSWING_OPTS="-h 0.0.0.0 -j ${WEBSWING_DATA}/etc/jetty.properties -u ${WEBSWING_DATA}/etc/user.properties -c ${WEBSWING_DATA}/etc/webswing.config"
fi

if [ -z "${WEBSWING_JAVA_OPTS}" ]; then
  export WEBSWING_JAVA_OPTS="-Xmx128M -Djava.io.tmpdir=/var/tmp"
fi

if [ -z "${WEBSWING_LOG_FILE}" ]; then
  export WEBSWING_LOG_FILE="${WEBSWING_DATA}/log/webswing.out"
  export WEBSWING_LOG="${WEBSWING_LOG_FILE}"   # for fix bag in webswing.sh
fi

if [ -z "${WEBSWING_PID_FILE}" ]; then
  export WEBSWING_PID_FILE="/var/run/webswing.pid"
fi

# Create any missing folders
mkdir -p "${WEBSWING_DATA}/log"
mkdir -p "${WEBSWING_DATA}/data/"

if [[ ! -e "${WEBSWING_DATA}/etc/" ]]; then
  mkdir -p "${WEBSWING_DATA}/etc"
  cp -R "${WEBSWING_HOME}/ssl" "${WEBSWING_DATA}/etc/"
  cp -R "${WEBSWING_HOME}/fonts" "${WEBSWING_DATA}/etc/"
fi

if [ ! -f "${WEBSWING_DATA}/etc/user.properties" ]; then
  if [ -z "${WEBSWING_ADMIN_PASSWD}" ]; then
    cp "${WEBSWING_HOME}/user.properties" "${WEBSWING_DATA}/etc/"
  else
    echo "#user.<username>=<password>[,role1][,role2]..." > "${WEBSWING_DATA}/etc/user.properties"
    echo "user.admin=\"${WEBSWING_ADMIN_PASSWD}\",admin" >> "${WEBSWING_DATA}/etc/user.properties"
  fi
fi

if [ ! -f "${WEBSWING_DATA}/etc/webswing.config" ]; then
  cp "${WEBSWING_HOME}/webswing.config" "${WEBSWING_DATA}/etc/"
  cp -R ${WEBSWING_HOME}/demo "${WEBSWING_DATA}/"
fi

if [ ! -f "${WEBSWING_DATA}/etc/jetty.properties" ]; then
  cat "${WEBSWING_HOME}/jetty.properties" | sed "s/=ssl/=etc\/ssl/" > "${WEBSWING_DATA}/etc/jetty.properties"
fi

webswing_stop() {
  if [ -f "${WEBSWING_PID_FILE}" ]; then
    echo "Webswing stoping ..."
    kill -9 $(cat "${WEBSWING_PID_FILE}"); sleep 5;
    if [ `ps -axo pid | grep "$(cat "${WEBSWING_PID_FILE}")" | wc -l` -eq 0 ]; then
      echo "Webswing stopped ..."
      rm -f "${WEBSWING_PID_FILE}"
    else
      echo "Stopping Webswing failed."
      exit 1
    fi
  fi
}

if [ -f "${WEBSWING_PID_FILE}" ] && [ `ps -axo pid | grep "$(cat "${WEBSWING_PID_FILE}")" | wc -l` -ne 0 ]; then
    echo "Webswing is already running with pid $(cat "${WEBSWING_PID_FILE}")"
    webswing_stop
fi

echo "Starting Webswing... "
echo "HOME:${WEBSWING_HOME}"
echo "OPTS:${WEBSWING_OPTS}"
echo "JAVA_HOME:$JAVA_HOME"
echo "JAVA_OPTS:${WEBSWING_JAVA_OPTS}"
echo "LOG:${WEBSWING_LOG_FILE}"
echo "PID:${WEBSWING_PID_FILE}"

exec xvfb-run "${WEBSWING_HOME}/webswing.sh" run
