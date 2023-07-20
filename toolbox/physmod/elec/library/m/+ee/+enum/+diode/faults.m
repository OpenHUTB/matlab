classdef faults<int32



    enumeration
        open(1)
        short(2)
        parameter(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('open')='physmod:ee:library:comments:enum:diode:faults:map_Open';
            map('short')='physmod:ee:library:comments:enum:diode:faults:map_Short';
            map('parameter')='physmod:ee:library:comments:enum:diode:faults:map_ParameterShift';
        end
    end
end