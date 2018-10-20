# Basic Code

require "Open3"

module Show
    def show
        puts to_s
    end
end

class Thing
    include Show
    
    attr_accessor :name

    def initialize(name)
        <<~DOC
        Arguments
        ------
        name: The name of the thing
        DOC
        @name = name
    end


end

class Player < Thing
end


def say(s)
    Open3.popen2("say", s)
end

def sayx(s)
    puts s
    Open3.popen2("say", s)
end
