# とあるプロジェクト

WebサーバとVueのフロントエンドからなる、とあるダミーのプロジェクトです。


## require

docker, docker-compose


## build

```
$ build/build.sh
```

### ブランチを指定してbuild

```
$ build/build.sh <branch> [<image-revision>]
```


## 開発環境立ち上げ

```
$ docker-compose up -d
```

### 開発環境の中で作業する

```
$ docker-compose exec server bash
```


## build済みコンテナの実行

* サーバモード
```
$ docker run -i -t -p 8000:8000 --rm otolab/toaru-project:ci-master server
```

* bashモード
```
$ docker run -i -t -p 8000:8000 --rm otolab/toaru-project:ci-master shell
```


