class Player
  def play_turn(warrior)
    @health ||= warrior.health
    (warrior.pivot!; return) if warrior.feel.wall?

    case
    when warrior.feel(:backward).enemy?
      warrior.attack! :backward
    when warrior.feel(:backward).captive?
      warrior.rescue! :backward
    when warrior.feel(:backward).wall?, warrior.feel(:backward).stairs?
      @dist = :forward
    when warrior.feel(:backward).empty?
      warrior.walk! :backward
    else
    end unless @dist

    case
    when warrior.feel.captive?
      warrior.rescue!
    when warrior.feel.empty?
      warrior.look[1].enemy? ? warrior.shoot! : rest_or_walk(warrior)
    else
      warrior.attack!
    end if @dist

    @health = warrior.health
  end

  def rest_or_walk warrior
    case
    when warrior.health < @health
      warrior.walk!(warrior.health < 10 ? :backward : :forward)
    when warrior.health < 20
      warrior.look.map(&:enemy?).map{|e| true unless e} == [true, true, true] ? 
        warrior.walk! : warrior.rest!
    else
      warrior.walk!
    end
  end
end
