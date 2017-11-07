#!/bin/sh

if [ $TRAVIS_OS_NAME = "linux" ]
then
  echo "Installing oracle instant client for linux..."

elif [ $TRAVIS_OS_NAME = "osx" ] then
  echo "Installing oracle instant client for linux..."

else
  echo "Don't know how to install oracle instant client for '$TRAVIS_OS_NAME'"
fi
