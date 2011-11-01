class Player
  DIRS = [:forward, :left, :right, :backward]
  FROM = {forward: :backward, left: :right}
  FROM.merge! FROM.invert

  def play_turn(warrior)
    @ticking = false
    d = decide_direction warrior
    look_arround warrior, d unless @looked
   
    if @enemies.length == 1
      if @ticking
        d = (DIRS.map{|dir| dir if warrior.feel(dir).empty?} - [nil]).first
        d = @enemies.first if d == FROM[@from]
      else
        d = @enemies.first
      end
    end
    
    case
    when @enemies.length > 1
      warrior.bind! @enemies.shift
    when do_rest?(warrior)
      warrior.rest!
    when @captives.length > 0
      warrior.rescue! @captives.shift
    when warrior.feel(d).enemy?
      warrior.look(d)[1].enemy? ? (warrior.detonate!(d); @detonated = true) : warrior.attack!(d)
    else
      warrior.walk! d
      @looked, @from = false, d
    end
  end
  
  def do_rest? warrior
    return false unless warrior.listen.map{|s| s.enemy?}.delete(true)
    n = @ticking ? 0 : 20
    n = 10 if @detonated
    warrior.health < n and !DIRS.map{|d| warrior.feel(d).enemy?}.delete(true)
  end
  
  def look_arround warrior, d
    @enemies, @captives = [], []
    DIRS.each do |dir|
      @enemies.push dir if warrior.feel(dir).enemy?
      @captives.push dir if warrior.feel(dir).captive?
    end
    (@enemies.delete d; @enemies << d) if @enemies.include? d
    @looked = true
  end
  
  def decide_direction warrior
    captives = (warrior.listen.map{|s| warrior.direction_of s if s.to_s == 'Captive'} - [nil]).uniq
    tickings = (warrior.listen.map{|s| warrior.direction_of s if s.ticking?} - [nil]).uniq
    @ticking = true unless tickings.empty?
    tickings.each{|d| captives.delete d; captives.unshift d}
    if warrior.direction_of_stairs == captives[0]
      dirs = DIRS.map{|d| d if !(warrior.feel(d).wall? or warrior.feel(d).stairs?)} - [nil]
      dirs.include?(captives[0]) ? captives[0] : dirs[0]
    else
      captives.empty? ? warrior.direction_of_stairs : captives[0]
    end
  end
end
