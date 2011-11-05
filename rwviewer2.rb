require 'stringio'
require 'ruby_warrior'
require 'green_shoes'
require_relative 'rw'

num = ask 'Enter: 1)Beginner 2)Intermediate'
num = '1' unless num == '2'

Shoes.app title: "Viewer 2 for Ruby Warrior - #{num == '1' ? 'Beginner' :  'Intermediate'} Tower" do
  style Shoes::Para, stroke: white
  style Shoes::Subtitle, stroke: white
  @turns = {}
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
