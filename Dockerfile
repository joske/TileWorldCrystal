FROM crystallang/crystal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y libgtk-3-dev libgirepository1.0-dev

WORKDIR /usr/src/app

COPY shard.yml /usr/src/app/

RUN shards install --ignore-crystal-version

COPY . /usr/src/app/

RUN crystal build src/tileworld.cr

CMD [ "./tileworld" ]
