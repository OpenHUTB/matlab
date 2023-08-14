classdef heatsinkConvection<int32




    enumeration
        natural(0)
        specifyFlowSpeed(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('natural')='physmod:ee:library:comments:enum:passive:thermal:heatsinkConvection:map_Natural';
            map('specifyFlowSpeed')='physmod:ee:library:comments:enum:passive:thermal:heatsinkConvection:map_SpecifyFlowSpeed';
        end
    end
end
