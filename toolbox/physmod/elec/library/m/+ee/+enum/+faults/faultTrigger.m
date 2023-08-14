classdef faultTrigger<int32



    enumeration
        temporal(1)
        behavioral(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('temporal')='physmod:ee:library:comments:enum:faults:faultTrigger:map_Temporal';
            map('behavioral')='physmod:ee:library:comments:enum:faults:faultTrigger:map_Behavioral';
        end
    end
end
