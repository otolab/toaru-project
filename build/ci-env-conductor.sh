#!/bin/bash

echo テスト環境の初期化処理
echo "usage: $0 [<pubsub_host>:<pubsub_port>] [<bigtable_host>:<bigtable_port>]"

set -ex

SCRIPT_DIR=$(cd $(dirname $BASH_SOURCE); pwd)

env

source ~/google-cloud-sdk/path.bash.inc

export KARTE_IO_SYSTEM_FINGERPRINT=$(printf '%d%03d' $(date +%s) $(($RANDOM % 1000)))

PUBSUB=${PUBSUB_EMULATOR_HOST}
BIGTABLE=${BIGTABLE_EMULATOR_HOST}

PUBSUB_HOST=${PUBSUB%%:*}
PUBSUB_PORT=${PUBSUB##*:}

BIGTABLE_HOST=${BIGTABLE%%:*}
BIGTABLE_PORT=${BIGTABLE##*:}

if [ "x$PUBSUB_EMULATOR_HOST" != "x" ]; then
  $SCRIPT_DIR/../scripts/wait_for.sh port $PUBSUB_PORT 120 1 $PUBSUB_HOST
fi

$SCRIPT_DIR/../scripts/wait_for.sh port $BIGTABLE_PORT 120 1 $BIGTABLE_HOST

$SCRIPT_DIR/../scripts/gcp/init_bigtable_emulator.sh

(cd $SCRIPT_DIR/.. && npm run e2e-setup)

(cd $SCRIPT_DIR/.. && if npm run debug-no-mon migrate -- -c ./e2e-test/e2e-config.coffee; then echo 'done'; fi)

coffee $SCRIPT_DIR/../scripts/create-pubsub-topic-and-subscription.coffee


# FIXME:
# config.coffeeを配信するほうが良いかもしれない

cat | node << EOF
  const http = require('http')
  const server = http.createServer()
  server.on('request', function(req, res) {
    res.writeHead(200,{'Content-Type': 'text/plain'})
    res.write(process.env.KARTE_IO_SYSTEM_FINGERPRINT)
    res.end()
  })
  server.listen(8099)
  console.log('Standby, ready.')
EOF
