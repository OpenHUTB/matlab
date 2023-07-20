classdef faults<int32



    enumeration
        open(1)
        sourceShort(2)
        gateShort(3)
        parameter(4)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('open')='physmod:ee:library:comments:enum:mosfet:faults:map_Open';
            map('sourceShort')='physmod:ee:library:comments:enum:mosfet:faults:map_DrainSourceShort';
            map('gateShort')='physmod:ee:library:comments:enum:mosfet:faults:map_GateOxideShort';
            map('parameter')='physmod:ee:library:comments:enum:mosfet:faults:map_ParameterShift';
        end
    end
end