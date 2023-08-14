classdef heatsinkParam<int32




    enumeration
        datasheet(1)
        tabulatedFin(2)
        rectangularFin(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('datasheet')='physmod:ee:library:comments:enum:passive:thermal:heatsinkParam:map_Datasheet';
            map('tabulatedFin')='physmod:ee:library:comments:enum:passive:thermal:heatsinkParam:map_TabulatedFin';
            map('rectangularFin')='physmod:ee:library:comments:enum:passive:thermal:heatsinkParam:map_RectangularFin';
        end
    end
end
