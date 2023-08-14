classdef structure<int32



    enumeration
        R(1)
        L(2)
        C(3)
        SeriesRL(4)
        SeriesRC(5)
        SeriesLC(6)
        SeriesRLC(7)
        ParallelRL(8)
        ParallelRC(9)
        ParallelLC(10)
        ParallelRLC(11)
    end
    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('R')='physmod:ee:library:comments:enum:rlc:structure:map_R';
            map('L')='physmod:ee:library:comments:enum:rlc:structure:map_L';
            map('C')='physmod:ee:library:comments:enum:rlc:structure:map_C';
            map('SeriesRL')='physmod:ee:library:comments:enum:rlc:structure:map_SeriesRL';
            map('SeriesRC')='physmod:ee:library:comments:enum:rlc:structure:map_SeriesRC';
            map('SeriesLC')='physmod:ee:library:comments:enum:rlc:structure:map_SeriesLC';
            map('SeriesRLC')='physmod:ee:library:comments:enum:rlc:structure:map_SeriesRLC';
            map('ParallelRL')='physmod:ee:library:comments:enum:rlc:structure:map_ParallelRL';
            map('ParallelRC')='physmod:ee:library:comments:enum:rlc:structure:map_ParallelRC';
            map('ParallelLC')='physmod:ee:library:comments:enum:rlc:structure:map_ParallelLC';
            map('ParallelRLC')='physmod:ee:library:comments:enum:rlc:structure:map_ParallelRLC';
        end
    end
end
