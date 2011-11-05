require 'stringio'
require 'ruby_warrior'
require 'green_shoes'
require_relative 'rw'

module RW
  def run_rw
    @visible.hide
    [@board, @warrior, @captives, @slugs, @bigslugs, @stairs, @witches, @archers].flatten.each &:hide
    @ed.show
    @stdout.string = ''
    RubyWarrior::Runner.new(['-t', '0'], @stdin, @stdout).run
  end
  
  def show_visible
    @ed.hide
    @visible.show
    @turns[0] = @ed.text.split(/^- turn \d* -\n/)
    @num = @turns[0][0].split("\n").last.split.last
    @sw.text == 'auto' ? auto :  sbs
  end
  
  def show_turn n, i
    @level.text = "Level #{@num}"
    @turn.text = "- turn #{i} -"
    board, @msg.text = make_up @turns[n][i]
    visualize board
    flush
  end
end

class ShoesIO < StringIO
  def initialize app, stdout, *args
    @app, @stdout = app, stdout
    super *args
  end

  def gets
    res = @app.ask @stdout.string.split("\n").last
    @stdout.puts res
    res.to_s + "\n"
  end
end

Shoes.app title: "Viewer 3 for Ruby Warrior - New Challenge", height: 530 do
  style Shoes::Para, stroke: white
  style Shoes::Subtitle, stroke: white
  style Shoes::Link, stroke: "#ffffff", underline: false, weight: 'bold'
  style Shoes::LinkHover, stroke: "#ffffff", underline: false
  background deeppink..crimson
  nostroke
  
  @turns = {}
  extend RW
  load_images
  make_board

  @stdout = StringIO.new ''
  @stdin = ShoesIO.new self, @stdout, ''

  @ed = edit_box state: 'readonly', width: 500, height: 400
  @ed.hide.move 50, 50
  SP = ' '

  para
  para SP*5, link('Run Ruby Warrior'){run_rw}, SP*20, link('Show Visible'){show_visible}, width: 450
  f = flow(width: 100){@sw = para 'auto', align: 'center'}
  f.click{@sw.text = @sw.text == 'auto' ? 'step by step' : 'auto'}
  
  @visible = flow margin_left: 25 do
    flow width: 550, height: 350 do
      @level = subtitle
      @turn = para
      @board_area = stack(height: 10){}
      @msg = para
    end
  end
  
  animate do
    @ed.text = @stdout.string unless @ed.text == @stdout.string
  end
end
