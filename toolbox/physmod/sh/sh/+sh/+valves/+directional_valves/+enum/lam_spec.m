classdef lam_spec<int32





    enumeration
        pressure_ratio(1)
        Reynolds(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('pressure_ratio')='Pressure ratio';
            map('Reynolds')='Reynolds number';
        end
    end
end