require_relative "base"

$suits = ['♦', '♣', '♥', '♠']
$ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A']
$jokers = ['j', 'J']
$zeros = ['10', 'J', 'Q', 'K']

class Card < Thing
    # card
    attr_accessor :suit, :rank

    def initialize(suit='♠', rank='A')
        @suit, @rank = suit, rank
    end

    def Card.random
        Card.new($suits[rand(4).to_i], $ranks[rand(13).to_i])
    end

    def Card.random_list(n)
        Array.new(n) {Card.random}
    end

    def Card.fromStr(s)
        suit, rank = s[0], s[1]
        Card.new(suit, rank)
    end

    def to_s
        @suit + @rank
    end

    def <(other)
        (self.to_array <=> other.to_array) == -1
    end

    def <=(other)
        self == other or self < other
    end

    def ==(other)
        self.to_array == other.to_array
    end

    def to_array
        [$ranks.index(@rank), $suits.index(@suit)]
    end


    def to_number
        if @rank == "A"
            return 1
        end
        if $zeros.include?(@rank)
            return 0
        else
            return $ranks.index(@rank) + 2
        end
    end
end


module Order

    def major
        if self[0] < self[1]
            return self[1]
        else
            self[0]
        end
    end

    def minor
        if self[0] < self[1]
            return self[0]
        else
            self[1]
        end
    end


end
            

class Pair < Array
    include Show
    include Order

    def Pair.random
        Pair.new([Card.random, Card.random])
    end

    def Pair.fromStr(s)
        a, b = s.split
        Pair.new([Card.fromStr(a), Card.fromStr(b)])
    end

    def is_dual?
        self[0].rank == self[1].rank
    end

    def total
        total = self[0].to_number + self[1].to_number
        if total >= 10
            total %= 10
        end
        return total
    end

    def <(other)
        <<~DOC
        Rules
        ------
        1. not dual < dual
        2. small total < big total
        3. small major < big major

        Example
        ------
            (♣6  ♣Q) < (♦8  ♥8)
            (♣6  ♣Q) < (♣K  ♦10)
            (♣6  ♣Q) < (♠Q  ♣6)
        DOC
        if is_dual?
            if other.is_dual?
                if self.major < other.major
                    return true
                elsif self.major == other.major
                    return self.minor < other.minor
                else
                    return false
                end
            else
                return false
            end
        else
            if other.is_dual?
                return true
            else
                if total < other.total
                    return true
                elsif total == other.total
                    if self.major < other.major
                        return true
                    elsif self.major == other.major
                        return self.minor < other.minor
                    else
                        return false
                    end
                else
                    return false
                end
            end
        end
    end

    def to_s
        "(#{self.minor.to_s} #{self.major.to_s})"
    end

end

class Team < Array
    include Show
    include Order

    def Team.random
        Team.new([Pair.random, Pair.random])
    end

    def Team.fromCards(cards, n=1)
        p = []
        cards.each_with_index do |c, k|
            if k != 0 and k != n
                p << c
            end
        end
        p = Pair.new(p)
        Team.new([Pair.new([cards[0], cards[n]]), p])
    end

    def toCards
        [self.minor[0], self.minor[1], self.major[0], self.major[1]]
    end

    def rearange(n)
        cards = toCards
        Team.fromCards(cards, n)
    end

    def <=>(other)
        score = 0
        if self.minor < other.minor
            score -= 1
        elsif self.minor > other.minor
            score += 1
        end
        if self.major < other.major
            score -= 1
        elsif self.major > other.major
            score += 1
        end
    end

    def to_s
        "#{self.minor.to_s} || #{self.major.to_s}"
    end
end


class CardGame
    # attr_accessor :tests   # set attribute accessors

    # def initialize(n=4, tests=10)
    #     @n = n
    #     @tests = tests
    # end

    def get_cards(n=2)
        return Array.new(n) {Card.random}
    end

    def get_pair
        return Pair.random
    end

    def get_team
        return Team.random
    end

    def bet
        puts "How many do you bet?"
        STDIN.gets.chomp.to_i
    end

    def register(player)
        @player = player
    end

    def start
        puts <<~RULE
        play cards
        RULE

        puts "Let's begin."
        k = 0
        while k<3
            k += 1
            computer = get_pair
            player = get_pair
            money = bet
            computer.show
            player.show
            if computer < player
                puts 'U win'
            elsif computer == player
                puts 'draw'
            else
                puts 'U lose'
            end
        end
        puts "Game over. U win"
    end

end

# cg = CardGame.new
# cg.start

# require "thor"
 
# class CardGameCLI < Thor
#     # ruby game.rb play --tests 12
#     desc "CardGame", "play cards, have a good mood."
#     option :n, :type => :numeric, :default => 4
#     option :tests, :aliases => :t, :type => :numeric, :default => 10
#     def play
#         g = ABGame.new(n=options[:n], tests=options[:tests])
#         g.start
#     end
# end
 
# ABGameCLI.start(ARGV)
