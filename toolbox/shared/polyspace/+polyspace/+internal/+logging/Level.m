

classdef Level<uint32

    enumeration
        OFF(intmax('uint32'))
        SEVERE(1000)
        WARNING(900)
        INFO(800)
        CONFIG(700)
        FINE(600)
        FINER(500)
        FINEST(400)
        DEBUG(300)
        ALL(0)
    end

    methods(Static)



        function level=convert(level)
            if ischar(level)
                level=eval(['polyspace.internal.logging.Level.',level]);
            elseif~isa(level,'polyspace.internal.logging.Level')
                level=polyspace.internal.logging.Level(level);
            end

        end

    end
end