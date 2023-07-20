classdef SystemLevelOutletSpecCondenser2P<int32





    enumeration
        Subcooling(1)
        Enthalpy(2)
        Quality(3)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Subcooling')='Subcooling';
            map('Enthalpy')='Specific enthalpy';
            map('Quality')='Vapor quality';
        end
    end
end