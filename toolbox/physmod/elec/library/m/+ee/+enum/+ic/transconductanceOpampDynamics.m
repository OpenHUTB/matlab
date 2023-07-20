classdef transconductanceOpampDynamics<int32





    enumeration
        no(1)
        finite(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:ic:transconductanceOpampDynamics:map_NoLag';
            map('finite')='physmod:ee:library:comments:enum:ic:transconductanceOpampDynamics:map_FiniteBandwidthWithSlewRateLimiting';
        end
    end
end