# tileworld

adapted from TileWorldRuby in Crystal

## Installation

shards install

## Usage

crystal run src/tileworld.cr

# Docker

docker build -t tileworld .

docker run -ti -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:rw --volume="$HOME/.Xauthority:/root/.Xauthority:rw" --network=host --privileged --rm --init tileworld