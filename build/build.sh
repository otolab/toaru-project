#!/bin/bash

cd $(dirname $BASH_SOURCE)

set -e

# もし試す場合はpush可能なdockerリポジトリを作ってから行ってください
REPOSITORY="otolab/toaru-project"
BASE_REPOSITORY="otolab/toaru-project-base"

# こちらの2つは頻繁に変える必要なし
ENV_VERSION="1.0.0"
BUILD_ENV_VERSION="1.0.0"

# ターゲットにするブランチ
DEFAULT_TARGET=$(git branch --contains | head -1 | sed -e 's/* //g')
BUILD_TARGET=${1:-${DEFAULT_TARGET}}

# CI ImageがベースにするリリースImageのバージョンを調べる
# 基盤にしたReleaseバージョンを取得したい
# リポジトリに書いておくのも一つ
# 今回はgitのタグから取得する。Cloneが増えて微妙ではある
PREV_TARGET_VERSION=$(git tag | grep -B 1 $BUILD_TARGET | head -1)
if ! git tag | grep $BUILD_TARGET &> /dev/null; then
  echo tag not found: $BUILD_TARGET
  if ! git branch -a | grep origin/$BUILD_TARGET &> /dev/null; then
    echo branch not found: origin/$BUILD_TARGET
    false
  else
    PREV_TARGET_VERSION=$(git describe --tags | cut -f 1 -d '-')
    if ! git tag | grep "$PREV_TARGET_VERSION" &> /dev/null; then
      echo 'base version tag not found'
      false
    fi
  fi
else
  echo target not found
  exit 1
fi

BUILD_VERSION=${2:-$(echo $BUILD_TARGET | sed s:/:_:g)}

echo "build image $BUILD_VERSION (target: $BUILD_TARGET)"
echo "prev: $PREV_TARGET_VERSION"

function check_and_pull {
  # return 1
  if ! [ "$(docker images -q $1)" = "" ]; then
    echo 'already exist'
    return 0
  fi
  docker pull $1
  return $?
}


# 実行環境の構築
# local, repositoryがキャッシュになる
if ! check_and_pull $BASE_REPOSITORY:$ENV_VERSION; then
  docker build -t $BASE_REPOSITORY:$ENV_VERSION \
    -f Dockerfile-base  .
  if ! docker push $BASE_REPOSITORY:$ENV_VERSION; then
    echo 'docker pushできませんでいした。push可能なリポジトリを指定してください'
  fi
fi

# 開発用実行環境の構築
if ! check_and_pull $BASE_REPOSITORY:dev-$BUILD_ENV_VERSION; then
  docker build -t $BASE_REPOSITORY:dev-$BUILD_ENV_VERSION \
    --build-arg BASE_REPOSITORY=$BASE_REPOSITORY \
    --build-arg ENV_VERSION=$ENV_VERSION \
    -f Dockerfile-develop-base  .
  if ! docker push $BASE_REPOSITORY:dev-$BUILD_ENV_VERSION; then
    echo 'docker pushできませんでいした。push可能なリポジトリを指定してください'
  fi
fi

# 分岐元のフルreleaseブランチを作る
# local, repositoryがキャッシュになる
if ! check_and_pull $REPOSITORY:release-$PREV_TARGET_VERSION; then
  docker build -t $REPOSITORY:release-$PREV_TARGET_VERSION \
    --build-arg BASE_REPOSITORY=$BASE_REPOSITORY \
    --build-arg BUILD_ENV_VERSION=$BUILD_ENV_VERSION \
    --build-arg BUILD_TARGET=$PREV_TARGET_VERSION \
    -f Dockerfile-develop .
  if ! docker push $REPOSITORY:release-$PREV_TARGET_VERSION; then
    echo 'docker pushできませんでいした。push可能なリポジトリを指定してください'
  fi
fi

# 今回のCIのターゲットとなるImageの作成
date +%s > rebuild.touch
docker build -t $REPOSITORY:ci-$BUILD_VERSION \
  --build-arg REPOSITORY=$REPOSITORY \
  --build-arg BUILD_TARGET=$BUILD_TARGET \
  --build-arg PREV_TARGET_VERSION=$PREV_TARGET_VERSION \
  -f Dockerfile-ci .
if ! docker push $REPOSITORY:ci-$BUILD_VERSION; then
  echo 'docker pushできませんでいした。push可能なリポジトリを指定してください'
fi

# ブランチがreleaseブランチであるとき、production Imageを作成する
if [ ${BUILD_TARGET%%/*} = 'release' ]; then
  RELEASE_VERSION=${BUILD_TARGET##*/}
  docker build -t $REPOSITORY:production-$RELEASE_VERSION \
    --build-arg BASE_REPOSITORY=$BASE_REPOSITORY \
    --build-arg REPOSITORY=$REPOSITORY \
    --build-arg ENV_VERSION=$ENV_VERSION \
    --build-arg BUILD_TARGET=$BUILD_TARGET \
    --build-arg CI_BUILD=ci-$BUILD_VERSION \
    -f Dockerfile-production .
  if ! docker push $REPOSITORY:production-$RELEASE_VERSION; then
    echo 'docker pushできませんでいした。push可能なリポジトリを指定してください'
  fi
fi

