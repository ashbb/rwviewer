require 'stringio'
require 'ruby_warrior'
require 'green_shoes'
require_relative 'rw'

module RW
  def show_turn n, i
    @msg.text = code("- turn #{i} -\n" + @turns[n][i])
    flush
  end
end

num = ask 'Enter: 1)Beginner 2)Intermediate'
num = '1' unless num == '2'

Shoes.app title: "Viewer for Ruby Warrior - #{num == '1' ? 'Beginner' :  'Intermediate'} Tower" do
  @turns = {}
  extend RW

  background yellow
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

  nostroke
  rect 50, 50, 500, 430, fill: white, curve: 20
  flow margin: [75, 25, 0, 0] do
    flow width: 450, height: 350 do
      @level = subtitle
      @msg = para
    end
  end
end
