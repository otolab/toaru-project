#!/bin/bash

set -e

MODE=$1

if [ $MODE = 'server' ]; then
  cd namespaces/server
  exec npm run server
fi

if [ $MODE = 'debug-server' ]; then
  cd namespaces/server
  exec npm run debug
fi

if [ $MODE = 'shell' ]; then
  exec bash $*
fi

# 終わらないが何もしないプロセス
# containerの起動状態を保ち、docker-compose execなどで操作・作業する
exec tail -f /dev/null