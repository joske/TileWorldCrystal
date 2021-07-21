require "gobject/gtk"
require "cairo-gobject/cairo"
require "./grid"

class TileWorld < Gtk::Application
  ROWS = 40
  COLS = 40
  MAG  = 20
  TIMEOUT = 2000_u32

  def initialize(grid : Grid)
    super(application_id: "be.sourcery.tileworld")

    @grid = grid
    on_activate do |application|
      window = Gtk::ApplicationWindow.new(self)
      window.title = "TileWorld"
      window.connect "destroy" do
        window.destroy
      end
      frame = Gtk::Frame.new
      frame.shadow_type = Gtk::ShadowType::IN
      window.add frame

      drawing_area = Gtk::DrawingArea.new
      drawing_area.set_size_request COLS * MAG + 250, ROWS * MAG
      frame.add(drawing_area)

      drawing_area.connect "draw" do
        redraw(window, drawing_area)
        false
      end

      GLib.timeout_milliseconds(interval: TIMEOUT) {
        @grid.update
        @grid.printGrid
        redraw(window, drawing_area)
        rect = Gdk::Rectangle.new(0, 0, COLS * MAG + 250, ROWS * MAG)
        window.window.not_nil!.invalidate_rect(rect, false)
        # window.queue_drawing_area(drawing_area, 0, 0, COLS * MAG + 250, ROWS * MAG)
        true
      }
      window.show_all
    end
  end

  def redraw(window, drawing_area)
    cr = Gdk.cairo_create(window.window.not_nil!)
    cr.set_source_rgb(1, 1, 1)
    cr.fill
    cr.rectangle(0, 0, COLS * MAG, ROWS * MAG)
    (ROWS - 1).times { |r|
      (COLS - 1).times { |c|
        cr.set_source_rgb(0, 0, 0)
        location = Location.new(c, r)
        o = @grid.object(location)
        if o != nil
          x = c * MAG
          y = r * MAG
          if o.is_a? Agent
            drawAgent(drawing_area, cr, o, x, y)
          elsif o.is_a? Hole
            cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
            cr.fill
          elsif o.is_a? Tile
            drawTile drawing_area, cr, o, x, y
          elsif o.is_a? Obstacle
            cr.rectangle(x, y, MAG, MAG)
            cr.fill
          end
        end
      }
    }
    x = COLS * MAG + 50
    y = 20
    @grid.agents.each { |a|
      r, b, g = getColor(a.num)
      cr.set_source_rgb(r, g, b)
      id = a.num
      text = "Agent(#{id}): #{a.score}"
      draw_text cr, x, y + id * MAG, text
      cr.stroke
    }
  end

  def drawAgent(drawing_area, cr, a, x, y)
    r, b, g = getColor(a.num)
    cr.set_source_rgb(r, g, b)
    cr.rectangle(x, y, MAG, MAG)
    cr.stroke
    if a.hasTile
      cr.new_sub_path
      cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
      cr.stroke
      cr.new_sub_path
      draw_text(cr, x + MAG / 4, y + 3, a.tile.not_nil!.score.to_s)
      cr.stroke
    end
  end

  def drawTile(drawing_area, cr, tile, x, y)
    cr.arc(x + MAG / 2, y + MAG / 2, MAG / 2, 0, 2 * Math::PI)
    cr.stroke
    cr.new_sub_path
    draw_text(cr, x + MAG / 4, y + 3, tile.score.to_s)
    cr.stroke
  end

  def draw_text(cr, x, y, text)
    cr.move_to(x, y)
    cr.show_text(text)
  end

  def getColor(num)
    if num == 0
      return 0.0, 0.0, 255.0
    elsif num == 1
      return 255.0, 0.0, 0.0
    elsif num == 2
      return 0.0, 255.0, 0.0
    elsif num == 3
      return 128.0, 128.0, 0.0
    elsif num == 4
      return 0.0, 128.0, 128.0
    elsif num == 5
      return 128.0, 0.0, 128.0
    else
      return 0.0, 255.0, 255.0
    end
  end
end
