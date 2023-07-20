classdef fieldparameterization<int32



    enumeration
        voltage(1)
        current(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('voltage')='physmod:ee:library:comments:enum:sm:fieldparameterization:map_FieldCircuitVoltage';
            map('current')='physmod:ee:library:comments:enum:sm:fieldparameterization:map_FieldCircuitCurrent';
        end
    end
end

