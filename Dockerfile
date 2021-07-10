FROM crystallang/crystal

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update

RUN apt install -y libgtk-3-dev

WORKDIR /usr/src/app

COPY shard.yml /usr/src/app/

RUN shards install --ignore-crystal-version

COPY . /usr/src/app/

CMD [ "crystal", "run", "src/tileworld.cr" ]
