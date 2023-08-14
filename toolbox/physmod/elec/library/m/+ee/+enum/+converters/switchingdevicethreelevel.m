classdef switchingdevicethreelevel<int32



    enumeration
        gto(1)
        ideal(2)
        igbt(3)
        mosfet(4)
        averaged(5)
    end


    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('gto')='physmod:ee:library:comments:enum:converters:switchingdevice:map_GTO';
            map('ideal')='physmod:ee:library:comments:enum:converters:switchingdevice:map_IdealSemiconductorSwitch';
            map('igbt')='physmod:ee:library:comments:enum:converters:switchingdevice:map_IGBT';
            map('mosfet')='physmod:ee:library:comments:enum:converters:switchingdevice:map_MOSFET';
            map('averaged')='physmod:ee:library:comments:enum:converters:switchingdevice:map_Averaged';
        end
    end
end
