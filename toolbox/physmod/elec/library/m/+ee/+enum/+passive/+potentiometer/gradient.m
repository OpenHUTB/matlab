classdef gradient<int32



    enumeration
        higherR(1)
        higherL(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('higherR')='physmod:ee:library:comments:enum:passive:potentiometer:gradient:HigherAtR';
            map('higherL')='physmod:ee:library:comments:enum:passive:potentiometer:gradient:HigherAtL';
        end
    end
end
