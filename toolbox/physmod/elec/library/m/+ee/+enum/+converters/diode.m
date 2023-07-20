classdef diode<int32



    enumeration
        nodynamics(2)
        chargedynamics(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('nodynamics')='physmod:ee:library:comments:enum:converters:diode:map_DiodeWithNoDynamics';
            map('chargedynamics')='physmod:ee:library:comments:enum:converters:diode:map_DiodeWithChargeDynamics';
        end
    end
end
