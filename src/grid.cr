require "./objects"

ROWS = 40
COLS = 40

module Direction
  UP    = 1
  DOWN  = 2
  LEFT  = 3
  RIGHT = 4
end

class Location
  def initialize(col : Int32, row : Int32)
    @col = col
    @row = row
  end

  def row
    @row
  end

  def col
    @col
  end

  def nextLocation(dir)
    if (dir == Direction::UP)
      return Location.new(@col, @row - 1)
    elsif (dir == Direction::DOWN)
      return Location.new(@col, @row + 1)
    elsif (dir == Direction::LEFT)
      return Location.new(@col - 1, @row)
    else
      return Location.new(@col + 1, @row)
    end
  end

  def equal?(other)
    return @col == other.col && @row == other.row
  end

  def ==(other)
    return @col == other.col && @row == other.row
  end

  def eql?(other)
    return @col == other.col && @row == other.row
  end

  def hash
    return @col << 8 & @row.hash
  end

  def clone()
    Location.new(@col, @row)
  end

  def distance(other)
    return (self.col - other.col).abs + (self.row - other.row).abs
  end

  def getDirection(other)
    if @row == other.row
      if @col == other.col + 1
        return Direction::LEFT
      else
        return Direction::RIGHT
      end
    else
      if @row == other.row + 1
        return Direction::UP
      else
        return Direction::DOWN
      end
    end
  end

  def to_s
    "location(#{@col}, #{@row})"
  end
end

class Grid
  def initialize(numAgents = 0, numHoles = 0, numTiles = 0, numObstacles = 0)
    @numAgents = numAgents
    @numHoles = numHoles
    @numTiles = numTiles
    @numObstacles = numObstacles

    @agents = [] of Agent          # array, as the number of agents stays fixed
    @holes = Hash(Int32, Hole).new # hash because holes/tiles appear/disappear
    @tiles = Hash(Int32, Tile).new
    @obstacles = [] of Obstacle # also fixed
    @objects = Array(Array(GridObject | Nil)).new(COLS){Array(GridObject | Nil).new(ROWS, nil)}
  end

  def createObjects
    (@numAgents - 1).times { |i|
      location = randomFreeLocation
      agent = Agent.new(self, i, location)
      set_object(location, agent)
      @agents << agent
    }
    (@numHoles - 1).times { |i|
      createHole(i)
    }
    (@numTiles - 1).times { |i|
      createTile(i)
    }
    (@numObstacles - 1).times { |i|
      location = randomFreeLocation
      obst = Obstacle.new(i, location)
      set_object(location, obst)
      @obstacles << obst
    }
  end

  def agents
    @agents
  end

  def tiles
    @tiles
  end

  def holes
    @holes
  end

  def obstacles
    @obstacles
  end

  def object(location)
    if location.col > COLS - 1 || location.col < 0
      raise "Alles kapot: column out of range: #{location.col}"
    end
    if location.row > ROWS - 1 || location.row < 0
      raise "Alles kapot: row out of range: #{location.row}"
    end
    return @objects[location.col][location.row]
  end

  def set_object(location, o)
    @objects[location.col][location.row] = o
  end

  def createTile(num)
    score = rand(1..6)
    location = randomFreeLocation
    tile = Tile.new(num, location, score)
    set_object(location, tile)
    @tiles[num] = tile
  end

  def createHole(num)
    location = randomFreeLocation
    hole = Hole.new(num, location)
    set_object(location, hole)
    @holes[num] = hole
  end

  def removeTile(tile)
    @tiles.delete(tile.as(Tile).num)
    set_object(tile.as(Tile).location, nil)
    createTile(tile.as(Tile).num)
  end

  def removeHole(hole)
    @holes.delete(hole.as(Hole).num)
    set_object(hole.as(Hole).location, nil)
    createHole(hole.as(Hole).num)
  end

  def validLocation(location)
    return location.row >= 0 && location.row < ROWS - 1 && location.col >= 0 && location.col < COLS - 1
  end

  def freeLocation(location)
    validLocation(location) && object(location) == nil
  end

  def validMove(location, dir)
    return freeLocation(location.nextLocation(dir))
  end

  def randomFreeLocation
    col = rand(0..COLS - 1)
    row = rand(0..ROWS - 1)
    location = Location.new(col, row)
    while object(location) != nil
      col = rand(0..COLS - 1)
      row = rand(0..ROWS - 1)
      location = Location.new(col, row)
    end
    return location
  end

  def getClosestTile(location)
    closest = 1000000
    best = nil
    @tiles.each_value { |t|
      dist = location.distance(t.location)
      if dist < closest
        closest = dist
        best = t
      end
    }
    return best
  end

  def getClosestHole(location)
    closest = 1000000
    best = nil
    @holes.each_value { |h|
      dist = location.distance(h.location)
      if dist < closest
        closest = dist
        best = h
      end
    }
    return best
  end

  def update
    @agents.each() { |a|
      puts a
      origLocation = a.location
      a.update
      puts a
      newLocation = a.location
      set_object(origLocation, nil)
      set_object(newLocation, a)
    }
  end

  def printGrid
    print "  "
    (COLS - 1).times { |c|
      printf "%d", c % 10
    }
    (ROWS - 1).times { |r|
      puts
      printf "%02d", r
      (COLS - 1).times { |c|
        location = Location.new(c, r)
        o = object(location)
        if o != nil
          if o.is_a? Agent
            print "A"
          elsif o.is_a? Hole
            print "H"
          elsif o.is_a? Tile
            print "T"
          elsif o.is_a? Obstacle
            print "#"
          end
        else
          print "."
        end
      }
    }
    puts
    @agents.each { |a|
      id = a.num
      text = "Agent(#{id}): #{a.score}"
      puts text
    }
  end
end
