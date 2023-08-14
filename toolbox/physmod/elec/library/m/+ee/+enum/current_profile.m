classdef current_profile<int32



    enumeration
        continuous(0)
        discontinuous(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('continuous')='physmod:ee:library:comments:enum:current_profile:map_Smoothed';
            map('discontinuous')='physmod:ee:library:comments:enum:current_profile:map_UnsmoothedOrDiscontinuous';
        end
    end
end