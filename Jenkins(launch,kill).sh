
#!/bin/bash

PID=`ps -ef | grep 'jenkins.war' | grep -v grep | awk '{print $2}'`
if [[ "" !=  "$PID" ]]; then
  echo "killing jenkins : $PID"
  sudo kill -9 $PID
else
  sleep 1

  LOGS_DIR=/Users/liujiang/.jenkins/logs
  MAIN_JAR="-jar /Users/liujiang/development/jenkins.war --httpPort=8000 --enable-future-java"
  JAVA_ARGS="-server -Xms2048m -Xmx2048m -XX:NewSize=1500m -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:+PrintGCDetails -XX:+PrintHeapAtGC  -XX:ThreadStackSize=512 -Xloggc:${LOGS_DIR}/gc.log "
  # 1>>${LOGS_DIR}/stdout.log 2>>${LOGS_DIR}/stderr.log
  java ${MAIN_JAR} & echo "startup jenkins ..."

fi
