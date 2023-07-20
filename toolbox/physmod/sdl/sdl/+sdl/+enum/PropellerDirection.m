classdef PropellerDirection<int32




    enumeration
        Negative(-1)
        Positive(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('Negative')='physmod:sdl:library:enum:PropellerNegative';
            map('Positive')='physmod:sdl:library:enum:PropellerPositive';
        end
    end
end
