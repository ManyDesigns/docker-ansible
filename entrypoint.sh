#!/bin/sh
set -e
if [ "$1" = 'version' ]; then
  exec su-exec ansible ansible --version
elif [ "$1" = 'setup' ]; then
  # Gathers facts about remote hosts
  exec su-exec ansible ansible -m setup all
elif [ "$1" = 'makemeroot' ]; then
  exec sh
else
  # Run as ansible user all the command received
  exec su-exec ansible "$@"
fi
