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
            
$bound = 10
class DiceArray < Array
    include Show

    def DiceArray.random
        DiceArray.new([Dice.random, Dice.random, Dice.random])
    end

    def numbers
        collect {|d| d.number}
    end


    def is_luck?
        self[0] == self[1] and self[1] == self[2]
    end

    def total
        self[0].number + self[1].number + self[2].number
    end

    def small?
        self.total <= $bound
    end

    def big?
        self.total > $bound
    end

    def to_s
        a = Array.new(3) {|k| (self.collect {|d| d.to_s.split("\n")[k]}).join("    ")}
        a.join("\n")
    end

    def result
        if is_luck?
            "豹子"
        elsif small?
            "小"
        else
            "大"
        end
    end

end



class Gambler
    attr_accessor :money, :bet, :bet_what

    def initialize(name='John', money=100)
        @name, @money = name, money
        @bet = 0
    end

    def bet(money, what)
        @bet = money
        @bet_what = what
    end

    def win
        if bet_what == 3
            @money += @bet * 3
        else
            @money += @bet
        end
    end

    def lose
        @money -= @bet
    end

    def lose_all?
        @money < 0
    end
end

$uwin = '你赢了'
$ulose = '你输了'

class DiceGame
    attr_accessor :money, :rounds, :player   # set attribute accessors

    def initialize(money=100, rounds=3)
        @money = money
        @rounds = rounds
    end

    def bet
        say "请下注"
        puts "下赌注"
        m = STDIN.gets.chomp.to_i
        puts "押大押小 [1.大 2.小 3.豹子]"
        w = STDIN.gets.chomp.to_i
        @player.bet(m, w)
    end

    def register
        # register
        puts "注册（姓名、赌资）"
        n = STDIN.gets.chomp
        m = STDIN.gets.chomp.to_i
        @player = Gambler.new(n, m)
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
            
            puts "开......"
            say "开"
            dices.show
            puts dices.numbers.join(" ") + dices.result
            say dices.numbers.join(" ") + dices.result
            
            case @player.bet_what
            when 1
                if dices.small?
                    @player.win
                    sayx $uwin
                else
                    @player.lose
                    sayx $ulose
                end
            when 2
                if dices.big?
                    @player.win
                    sayx $uwin
                else
                    @player.lose
                    sayx $ulose
                end
            when 3
                if dices.is_luck?
                    @player.win
                    sayx uwin
                else
                    @player.lose
                    sayx ulose
                end
            end
            if @player.lose_all?
                sayx "你输光了"
                break
            end
        end
        puts "Game over."
    end

end


require "thor"
 
class DiceGameCLI < Thor
    # ruby game.rb play --tests 12
    desc "DiceGame", "play dices, have a good mood."
    option :money, :type => :numeric, :default => 100
    option :rounds, :aliases => :t, :type => :numeric, :default => 10
    def play
        g = DiceGame.new(money=options[:money], rounds=options[:rounds])
        g.register
        g.start
    end
end
 
DiceGameCLI.start(ARGV)
