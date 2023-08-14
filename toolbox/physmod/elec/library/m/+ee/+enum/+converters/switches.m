classdef switches<int32



    enumeration
        mosfet(1)
        igbt(2)
        gto(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('gto')='physmod:ee:library:comments:enum:converters:switches:map_GTO';
            map('igbt')='physmod:ee:library:comments:enum:converters:switches:map_IGBT';
            map('mosfet')='physmod:ee:library:comments:enum:converters:switches:map_MOSFET';
        end
    end
end
