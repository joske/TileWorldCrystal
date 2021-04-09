# TODO: Write documentation for `Tileworld`
require "./grid"

module Tileworld
  VERSION = "0.1.0"

  ROWS = 40
  COLS = 40
  MAG = 20
  RANDOM_MOVE_PERC = 20
  TIMEOUT = 200

  grid = Grid.new(6, 20, 20, 40)
  grid.createObjects
  while true
    grid.update
    grid.printGrid
  end
end
