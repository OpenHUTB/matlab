classdef PressureSpecification<int32





    enumeration
        Atmospheric(1)
        Specified(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Atmospheric')='Atmospheric pressure';
            map('Specified')='Specified pressure';
        end
    end
end