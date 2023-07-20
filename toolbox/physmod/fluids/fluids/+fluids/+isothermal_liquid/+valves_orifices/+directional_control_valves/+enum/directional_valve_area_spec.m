classdef directional_valve_area_spec<int32





    enumeration
        identical(1)
        different(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('identical')='Identical for all flow paths';
            map('different')='Different for each flow path';
        end
    end
end
