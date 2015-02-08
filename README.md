zumhotface-docker
=================


## Quickstart

This will get Zumhotface up and running.

Zumhotface uses PostgreSQL and Redis for datastore.

### PostgreSQL

Start a data volume instance of PostgreSQL:

```sh
docker run -d --name postgres-data -v /data busybox
```

Start PostgreSQL using data volume container:

```sh
docker run -d --name postgres --volumes-from postgres-data postgres:latest
```

### Redis

Do the same with redis. Start a data volume instance of redis:

```sh
docker run -d --name redis-data -v /data busybox
```

Start Redis using data volume container:

```sh
docker run -d --name redis --volumes-from redis-data redis:latest
```

### Application

Now we are ready to start Zumhotface container.
First start data volume container

```sh
docker run -d --name zhf-data -v /data busybox
```

Start application using data volume container:

```sh
docker run -p 8080:80 -d --name zhf \
           --volumes-from zhf-data \
           --link postgres:postgres \
           --link redis:redis \
           -e DB_HOST=postgres \
           -e REDIS_HOST=redis \
           -e ZHF_CREATE_USER=true \
           -e ZHF_SECRET_KEY=PuT_Very_lOnG_StRinG_HeRe \
           -e ZHF_ADMIN_EMAIL=your@email.com \
           -e ZHF_ADMIN_PASSWORD=password \
           digitalhelpersleague/zumhotface
```

Zumhotface will create a default user account with the username admin and the password zumhotface. Go to http://<yourhost.com>:8080 and get start
