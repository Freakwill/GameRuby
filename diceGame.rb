require_relative "base"

class Dice < Thing
    # card
    include Show
    attr_accessor :number

    def initialize(number=1)
        @number = number
    end

    def Dice.random
        Dice.new(rand(6).to_i + 1)
    end

    def Dice.random_list(n=3)
        Array.new(n) {Dice.random}
    end

    def to_s
        Dice.face(@number)
    end

    def ==(other)
        self.number == other.number
    end

    def Dice.face(n)
        dot = "@"
        case n
        when 1
            "   \n #{dot} \n   "
        when 2
            " #{dot} \n   \n #{dot} "
        when 3
            "#{dot}  \n #{dot} \n  #{dot}"
        when 4
            "#{dot} #{dot}\n   \n#{dot} #{dot}"
        when 5
            "#{dot} #{dot}\n #{dot} \n#{dot} #{dot}"
        when 6
            "#{dot} #{dot}\n#{dot} #{dot}\n#{dot} #{dot}"
        end
    end
end
            

class DiceArray < Array
    include Show

    def DiceArray.random
        DiceArray.new([Dice.random, Dice.random, Dice.random])
    end


    def is_luck?
        self[0] == self[1] and self[1] == self[2]
    end

    def total
        self[0].number + self[1].number + self[2].number
    end

    def small?
        self.total <= 10
    end

    def large?
        self.total >= 11
    end

    def to_s
        a = Array.new(3) {|k| (self.collect {|d| d.to_s.split("\n")[k]}).join("    ")}
        a.join("\n")
    end

end

d = DiceArray.random
puts d[0].number
puts d.to_s



class Gambler
    def initialize(name='John', money=100)
        @name, @money = name, money
        @bet = 0
    end

    def bet(money, what)
        @bet = money
        @bet_what = what
    end

    def win
        @money += @bet
    end

    def lose
        @money -= @bet
    end

    def lose_all?
        @money < 0
    end
end

class DiceGame
    # attr_accessor :tests   # set attribute accessors

    def initialize(money=100, rounds=3)
        @money = money
        @rounds = rounds
    end

    def get_cards(n=2)
        return Array.new(n) {Dice.random}
    end

    def get_pair
        return Pair.random
    end

    def get_team
        return Team.random
    end

    def bet
        puts "下赌注"
        m = STDIN.gets.chomp.to_i
        puts "押大押小 [1.大 2.小 3.豹子]"
        w = STDIN.gets.chomp.to_i
        @player.bet(m, w)
    end

    def register(player)
        @player = player
    end

    def start
        puts <<~RULE
        play cards
        RULE

        puts "Let's begin. Good Luck."
        k = 0
        while k < @rounds
            k += 1
            dices = DiceArray.random
            bet
            
            dices.show
            
            case @player.bet_what
            when 1
                if dices.small?
                    @player.win
                    puts 'U win'
                else
                    @player.lose
                    puts 'U lose'
                end
            when 2
                if dices.big?
                    @player.win
                    puts 'U win'
                else
                    @player.lose
                    puts 'U lose'
                end
            when 3
                if dices.is_luck?
                    @player.win
                    puts 'U win'
                else
                    @player.lose
                    puts 'U lose'
                end
            end
            if @player.total < 0
                puts 'U have no money!'
            end
        end
        puts "Game over."
    end

end

# cg = DiceGame.new
# cg.start

require "thor"
 
class DiceGameCLI < Thor
    # ruby game.rb play --tests 12
    desc "DiceGame", "play dices, have a good mood."
    option :money, :type => :numeric, :default => 4
    option :rounds, :aliases => :t, :type => :numeric, :default => 10
    def play
        g = DiceGame.new(money=options[:money], rounds=options[:rounds])
        g.register(Gambler.new)
        g.start
    end
end
 
DiceGameCLI.start(ARGV)
