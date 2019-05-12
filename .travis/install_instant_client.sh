-#!/bin/sh

if [ $TRAVIS_OS_NAME = "linux" ]
then
  echo "Installing oracle instant client for linux..."

  cd ./travis/oracle
  apt-get install -y oracle-instantclient12.2-basic-12.2.0.1.0-1.x86_64.rpm
  apt-get install -y oracle-instantclient12.2-devel-12.2.0.1.0-1.x86_64.rpm

else
  echo "Don't know how to install oracle instant client for '$TRAVIS_OS_NAME'"
fi
