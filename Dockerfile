FROM jhass/crystal:0.35.0-build

RUN sudo apt update

RUN sudo apt install -y libgtk-3-dev

WORKDIR /usr/src/app

COPY shard.yml /usr/src/app/

RUN shard install

COPY . /usr/src/app/

CMD [ "crystal", "run", "src/tileworld.cr" ]