classdef threePhasePort<int32




    enumeration
        composite(1)
        expanded(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('composite')='physmod:ee:library:comments:enum:threePhasePort:map_Composite';
            map('expanded')='physmod:ee:library:comments:enum:threePhasePort:map_Expanded';
        end
    end
end
