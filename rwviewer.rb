require 'stringio'
require 'ruby_warrior'
require 'green_shoes'

module RW
  def run_rw argv
    stdin = StringIO.new "1"
    stdout = StringIO.new ''
    RubyWarrior::Runner.new(argv, stdin, stdout).run
    stdout.string.split(/^- turn \d* -\n/)
  end

  def auto n
    e = every do |i|
      @msg.text = code("- turn #{i} -\n" + @turns[n][i])
      flush
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
      @msg.text = code("- turn #{i} -\n" + @turns[n][i])
      flush
    end
  end
end

Shoes.app title: 'Viewer for Ruby Warrior' do
  @turns = {}
  extend RW

  background yellow
  flow margin: [20, 10, 0, 0] do
    flow do
      9.times do |i|
        n = i + 1
        button "Level #{n}" do
          @level.text = "Level #{n}"
          @turns[n] = run_rw(["-l", n.to_s]) unless @turns[n]
          @msg.text = @turns[n][0]
          @sw.text == 'auto' ? auto(n) :  sbs(n)
        end
      end
      f = flow(width: 100, margin_top: 5){@sw = para 'auto', align: 'center'}
      f.click{@sw.text = @sw.text == 'auto' ? 'step by step' : 'auto'}
    end
  end

  nostroke
  rect 75, 75, 450, 350, fill: white, curve: 20
  flow margin: [100, 50, 0, 0] do
    flow width: 400, height: 300 do
      @level = subtitle
      @msg = para
    end
  end
end
