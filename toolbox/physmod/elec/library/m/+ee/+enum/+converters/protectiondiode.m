classdef protectiondiode<int32



    enumeration
        none(1)
        nodynamics(2)
        chargedynamics(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:converters:protectiondiode:map_None';
            map('nodynamics')='physmod:ee:library:comments:enum:converters:protectiondiode:map_ProtectionDiodeWithNoDynamics';
            map('chargedynamics')='physmod:ee:library:comments:enum:converters:protectiondiode:map_ProtectionDiodeWithChargeDynamics';
        end
    end
end
