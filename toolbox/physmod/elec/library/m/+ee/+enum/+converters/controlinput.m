classdef controlinput<int32



    enumeration
        dutycycle(1)
        current(2)
        voltage(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('dutycycle')='physmod:ee:library:comments:enum:converters:controlinput:map_DutyCycle';
            map('current')='physmod:ee:library:comments:enum:converters:controlinput:map_CurrentReference';
            map('voltage')='physmod:ee:library:comments:enum:converters:controlinput:map_VoltageReference';
        end
    end
end
