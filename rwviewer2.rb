require 'stringio'
require 'ruby_warrior'
require 'green_shoes'

module RW
  def run_rw argv, num
    stdin = StringIO.new num
    stdout = StringIO.new ''
    RubyWarrior::Runner.new(argv, stdin, stdout).run
    stdout.string.split(/^- turn \d* -\n/)
  end

  def auto n
    e = every do |i|
      show_turn n, i
      e.stop if i > @turns[n].length - 2
    end
  end

  def sbs n
    i, len = 0, @turns[n].length
    keypress do |k|
      case k
      when 'Up'
        i -= 1
        i = len - 1 if i <= 0
      when 'Down'
        i += 1
        i = 1 if i == len
      else
      end
      show_turn n, i
    end
  end
  
  def show_turn n, i
    @turn.text = "- turn #{i} -"
    board, @msg.text = make_up @turns[n][i]
    visualize board
    flush
  end
  
  def make_up turn
    board, msg = [], ''
    turn.split("\n").each do |line|
      case
      when line =~ /^\|/
        board << line[1...-1].split('')
      when line =~ /^ /
      else
        msg << line << "\n"
      end
    end
    return board, msg
  end
  
  def load_images
    @warrior = image './imgs/ninja.png', hidden: true, width: 49, height: 49, nocontrol: true
    @stairs = image './imgs/stairs_up.png', hidden: true, width: 49, height: 49, nocontrol: true
    @slugs, @sn = [], 0
    7.times{@slugs << image('./imgs/slug.png', hidden: true, width: 25, height: 25, nocontrol: true)}
    @bigslugs, @bn = [], 0
    2.times{@bigslugs << image('./imgs/slug.png', hidden: true, width: 49, height: 49, nocontrol: true)}
    @captives, @cn = [], 0
    2.times{@captives << image('./imgs/girl2.png', hidden: true, width: 29, height: 29, nocontrol: true)}
    @witches, @wn = [], 0
    2.times{@witches << image('./imgs/witch.png', hidden: true, width: 49, height: 49, nocontrol: true)}
    @archers, @an = [], 0
    2.times{@archers << image('./imgs/rifle.png', hidden: true, width: 49, height: 49, nocontrol: true)}
  end
  
  def make_board
    @board = Array.new(12){[]}
    12.times do |j|
      12.times do |i|
        @board[j] << rect(25+i*50, 120+j*50, 49, 49, fill: lightgrey, back: true, hidden: true)
      end
    end
  end
  
  def visualize board
    [@board, @warrior, @captives, @slugs, @bigslugs, @stairs, @witches, @archers].flatten.each &:hide
    @cn = @sn = @bn = @wn = @an= 0
    
    board.length.times do |j|
      board[0].length.times do |i|
        @board[j][i].show
      end
    end
    
    board.each_with_index do |cells, j|
      cells.each_with_index do |cell, i|
        x, y = 25+i*50, 120+j*50
        case cell
        when '@'
          @warrior.move(x, y).show
        when 'C'
          @captives[@cn].move(x+10, y+10).show; @cn+=1
        when 's'
          @slugs[@sn].move(x+24, y+24).show; @sn+=1
        when 'S'
          @bigslugs[@bn].move(x, y).show; @bn+=1
        when 'w'
          @witches[@wn].move(x, y).show; @wn+=1
        when 'a'
          @archers[@an].move(x, y).show; @an+=1
        when '>'
          @stairs.move(x, y).show
        else
        end
      end
    end
    
    @board_area.style height: board.length * 50 + 10
  end
end

num = ask 'Enter: 1)Beginner 2)Intermediate'
num = '1' unless num == '2'

Shoes.app title: "Viewer 2 for Ruby Warrior - #{num == '1' ? 'Beginner' :  'Intermediate'} Tower" do
  style Shoes::Para, stroke: white
  style Shoes::Subtitle, stroke: white
  @turns, @boards = {}, Array.new(9){[]}
  extend RW

  background cornflowerblue..navy
  nostroke
  load_images
  make_board
  
  flow margin: [20, 10, 0, 0] do
    flow do
      9.times do |i|
        n = i + 1
        button "Level #{n}" do
          @level.text = "Level #{n}"
          @turns[n] = run_rw(['-l', n.to_s, '-t', '0'], num) unless @turns[n]
          @msg.text = @turns[n][0]
          @sw.text == 'auto' ? auto(n) :  sbs(n)
        end
      end
      f = flow(width: 100, margin_top: 5){@sw = para 'auto', align: 'center'}
      f.click{@sw.text = @sw.text == 'auto' ? 'step by step' : 'auto'}
    end
  end

  flow margin_left: 25 do
    flow width: 450, height: 350 do
      @level = subtitle
      @turn = para
      @board_area = stack(height: 10){}
      @msg = para
    end
  end
end
