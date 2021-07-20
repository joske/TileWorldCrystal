require "./astar"

module State
  IDLE = 0
  MOVE_TO_TILE = 1
  MOVE_TO_HOLE = 2
end

class GridObject
  def initialize(num : Int32, location : Location)
    @num = num
    @location = location
  end

  def col
    @location.col
  end

  def row
    @location.row
  end

  def num
    @num
  end

  def location
    @location
  end

  def equal?(other)
    @num == other.as(GridObject).num && @location == other.as(GridObject).location && self.class == other.class
  end

  def to_s
    "#{self.class.name} #{@num} at #{location}"
  end
end

class Agent < GridObject
  property score

  def initialize(grid : Grid, num : Int32, location : Location)
    super num, location
    @grid = grid
    @state = State::IDLE
    @tile = nil.as(Tile?)
    @hole = nil.as(Hole?)
    @score = 0
    @path = [] of Location
    @hasTile = false
  end

  # updates the location of this agent
  def nextMove(loc)
    puts "move #{loc}"
    @location = loc
  end

  def location()
    @location
  end

  def hasTile
    @hasTile
  end

  def set_tile(tile)
    @tile = tile
  end

  def tile
    @tile
  end

  def update
    if @state == State::IDLE
      idle
    elsif @state == State::MOVE_TO_TILE
      moveToTile
    else
      moveToHole
    end
  end

  def idle
    @tile = nil
    @hole = nil
    @hasTile = false
    puts "#{self} finding tile"
    @tile = @grid.getClosestTile(@location)
    puts "#{self} found tile #{@tile}"
    @state = State::MOVE_TO_TILE
  end

  def moveToTile
    if @tile.as(Tile).location.equal? self.location
      # we have arrived
      pickTile
      @hole = @grid.getClosestHole(@location)
      @state = State::MOVE_TO_HOLE
      return
    end
    # check if our tile is still there
    o = @grid.object(@tile.as(Tile).location)
    if o === nil || !o.as(GridObject).equal?(@tile)
      puts "#{self} our tile is gone"
      @state = State::IDLE
      return
    end
    # try to find a closer tile
    potentialTile = @grid.getClosestTile(@location).as(GridObject)
    if !potentialTile.equal?(@tile)
      puts "#{self} tile #{potentialTile} is now closer than #{@tile}"
      @tile = potentialTile
    end
    if @path.empty?
      @path = astar(@grid, @location, @tile.as(Tile).location)
      puts "#{self} path: #{@path}"
    else
      nextLoc = @path.shift
      if @grid.validLocation(nextLoc) || nextLoc.equal?(@tile.as(Tile).location)
        nextMove(nextLoc)
      else
        # hmm, something in the way suddenly
        @path = astar(@grid, @location, @tile.as(Tile).location)
      end
    end
  end

  def pickTile
    puts "agent #{@num}: pickTile"
    @hasTile = true
    @grid.removeTile(@tile)
  end

  def moveToHole
    if @location.equal? @hole.as(Hole).location
      # we have arrived
      dumpTile
      return
    end
    # check if our hole is still there
    o = @grid.object(@hole.as(Hole).location)
    if o === nil || !o.as(GridObject).equal?(@hole)
      puts "#{self} our hole is gone"
      @hole = @grid.getClosestHole(@location)
      return
    end
    # try to find a closer hole
    potentialHole = @grid.getClosestHole(@location).as(Hole)
    if !potentialHole.equal?(@hole)
      puts "#{self} tile #{potentialHole} is now closer than #{@hole}"
      @hole = potentialHole
    end
    if @path.empty?
      @path = astar(@grid, self.location, @hole.as(Hole).location)
      puts "#{self} path: #{@path}"
    else
      nextLoc = @path.shift
      if @grid.validLocation(nextLoc) || nextLoc.equal?(@hole.as(Hole).location)
        nextMove(nextLoc)
      else
        @path = astar(@grid, @location, @hole.as(Hole).location)
      end
    end
  end

  def dumpTile
    puts "agent #{@num}: dumpTile"
    @score += @tile.as(Tile).score
    @tile = nil
    @hasTile = false
    @grid.removeHole(@hole)
    @hole = nil
    @state = State::IDLE
  end

  def to_s
    return "Agent #{@num} at #{@location} in state #{@state} hasTile=#{@hasTile} tile=#{@tile} hole=#{@hole}"
  end
end

class Hole < GridObject
end

class Tile < GridObject
  def initialize(num : Int32, location : Location, score : Int32)
    super num, location
    @score = score
  end
  def score
    @score
  end
end

class Obstacle < GridObject
end
