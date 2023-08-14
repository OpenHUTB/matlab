classdef lossesOption<int32



    enumeration
        proportionalToSquaredCurrent(1)
        tabulated(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('proportionalToSquaredCurrent')='physmod:ee:library:comments:enum:converters:lossesOption:map_ProportionalToSquaredCurrent';
            map('tabulated')='physmod:ee:library:comments:enum:converters:lossesOption:map_Tabulated';
        end
    end
end
