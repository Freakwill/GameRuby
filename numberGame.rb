# 猜数字游戏的一种变体允许重复的数码。这种规则的游戏被称为 Mastermind 。其规则大致为：
# 如果有出现重复的数字，则重复的数字每个也只能算一次，且以最优的结果为准。
# 例如，如正确答案为5543，猜的人猜5255，则在这里不能认为猜测的第一个5对正确答案第二个，根据最优结果为准的原理和每个数字只能有一次的规则，两个比较后应该为1A1B，第一个5位子正确，记为1A。
# 猜测数字中的第三个5或第四个5和答案的第二个5匹配，只能记为1B。当然，如果有猜5267中的第一个5不能与答案中的第二个5匹配，因此只能记作1A0B。

class ABGame
    attr_accessor :tests   # set attribute accessors

    def initialize(n=4, tests=10)
        @n = n
        @tests = tests
    end

    def get_numbers
        return Array.new(@n) {|k| rand(10).to_i}
    end

    def check(guess)
        if guess.length != @n
            raise "Input #{@n} numbers!"
        end
        guess.each do |x|
            if not x.is_a?(Integer)
                raise "Input integers from 0-9!"
            end
        end
    end

    def guess_numbers
        guess = STDIN.gets.chomp
        guess = Array.new(@n) {|k| guess[k].to_i}
    end

    # def prompt
    #     i = rand(4).to_i
    #     a = Array.new(@n) {|k| '#'}
    #     a[i] = $numbers[i].to_s
    #     return a
    # end

    def start
        puts <<~RULE
        # 猜数字游戏的一种变体允许重复的数码。Mastermind 规则：
        # 如果有出现重复的数字，则重复的数字每个也只能算一次，且以最优的结果为准。
        # 例如，如正确答案为5543，猜的人猜5255，则在这里不能认为猜测的第一个5对正确答案第二个，根据最优结果为准的原理和每个数字只能有一次的规则，两个比较后应该为1A1B，第一个5位子正确，记为1A。
        # 猜测数字中的第三个5或第四个5和答案的第二个5匹配，只能记为1B。当然，如果有猜5267中的第一个5不能与答案中的第二个5匹配，因此只能记作1A0B。
        RULE

        puts "Let's begin. Input #{@n} numbers [0-9]"
        numbers = get_numbers
        k = 1
        while k <= @tests
            print "[#{k}] guess: "
            guess = guess_numbers
            a, b = ABGame.match(guess, numbers)
            if a == @n
                puts "Bingo!"
                return 1
            else
                puts "Prompt: #{a}A#{b}B"
                k += 1
            end
        end
        puts "Game over. The answer is #{numbers.join}"
    end

    def ABGame.match(guess, answer)
    <<~DOC
        Arguments
        ------
        guess, answer: Array with the same length

        Example
        ------
            ABGame.match([5,2,5,5],[5,5,4,3]) == [1, 1]
            ABGame.match([3,5,3,4],[6,5,3,4]) == [3, 0]
    DOC
        a = b = 0

        n = guess.length
        rem = Array(0...n)
        Array.new(n) do |k|
            if guess[k] == answer[k]
                a += 1
                rem.delete(k)
            end
        end
        if a == n
            return [4, 0]
        end
        copy = rem.collect {|k| answer[k]}
        rem.each do |k|
            ind = copy.index(guess[k])
            if ind
                b += 1
                copy.delete_at(ind)
            end
        end
        return [a, b]
    end

end

# class Pattern

#     attr_accessor :arr, :num

#     def initialize(arr, num=0)
#         @arr = arr
#         @num = num       
#     end
    
#     def Pattern.fromAB(answer, a, b)
#         l = answer.length
#         def get_arrays(answer, a)
#             arr = answer.clone
#             if a == 0
#                 arr = [answer.collect {|x| [x]}]  # {[x] : x in answer.collect}
#             elsif a == l
#                 arr = [answer]
#             else
#                 get_arrays(answer[1, l], a-1).each do |arr|
#                     arr1 = arr.push(answer[0])
#                 end
#                 get_arrays(answer[1, l], a).each do |arr|
#                     arr2 = arr.putsh([answer[0]])
#                 end
#                 arr = arr1 + arr2
#             end
#             return arr
#         end
#         arrs = get_arrays(answer, a)
#         return arrs.collect{|arr| in Pattern.new(arr, b)}
#     end

#     def +(other)
#         l = @.arr.length
#         res = Pattern.new(@.arr.clone)
#         Array.new(@.arr.length) do |k|
#             next unless @.arr[k] == other.arr[k]
#             if @.arr[k].is_a?(Array) and other.arr[k].is_a?(Array)
#                 res.arr = other.arr + @.arr
#                 if res.arr == [0..9].to_a
#                     res.arr = []
#                     return res
#             elsif @.arr[k].is_a?(Array) and other.arr[k].is_a?(Integer)
#                 if other.arr[k].include?(@.arr)
#                     res.arr = []
#                     return res
#                 else
#                     res.arr[k] = other.arr[k]
#                 end
#             elsif @.arr[k].is_a?(Integer) and other.arr[k].is_a?(Array)
#                 if @.arr[k].include?(other.arr)
#                     res.arr = []
#                     return res
#                 else
#                     res.arr[k] = @.arr[k]
#                 end
#                 res.arr = []
#                 return res
#             end
#         end
#         return res
#     end
# end


# Create a new object
# g = ABGame.new
# g.start

require "thor"
 
class ABGameCLI < Thor
    # ruby game.rb play --tests 12
    desc "ABGame", "play ab game, have a good mood."
    option :n, :type => :numeric, :default => 4
    option :tests, :aliases => :t, :type => :numeric, :default => 10
    def play
        g = ABGame.new(n=options[:n], tests=options[:tests])
        g.start
    end
end
 
ABGameCLI.start(ARGV)
