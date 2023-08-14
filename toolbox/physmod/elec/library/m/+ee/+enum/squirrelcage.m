classdef squirrelcage<int32


    enumeration
        Single(1)
        Double(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Single')='physmod:ee:library:comments:enum:squirrelcage:map_SingleSquirrelCage';
            map('Double')='physmod:ee:library:comments:enum:squirrelcage:map_DoubleSquirrelCage';
        end
    end

end
