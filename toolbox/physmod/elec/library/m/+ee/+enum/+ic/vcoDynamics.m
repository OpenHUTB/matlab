classdef vcoDynamics<int32





    enumeration
        no(0)
        yes(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:ic:vcoDynamics:map_NoDynamics';
            map('yes')='physmod:ee:library:comments:enum:ic:vcoDynamics:map_ModelFrequencyTrackingDynamics';
        end
    end
end