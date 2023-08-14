classdef mode<int32



    enumeration
        disabled(0)
        enabled(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('disabled')='physmod:ee:library:comments:enum:mode:map_Disabled';
            map('enabled')='physmod:ee:library:comments:enum:mode:map_Enabled';
        end
    end
end
