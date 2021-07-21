# TODO: Write documentation for `Tileworld`
require "./grid"
require "./gridview"

module Tileworld
  VERSION = "0.2.0"

  
  grid = Grid.new(6, 20, 20, 40)
  grid.createObjects
  app = TileWorld.new(grid: grid)
  app.run
  # while true
  #   grid.update
  #   grid.printGrid
  #   sleep 10
  # end
end
