classdef assertAction<int32



    enumeration
        none(0)
        warn(1)
        error(2)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('none')='physmod:ee:library:comments:enum:assertAction:map_None';
            map('warn')='physmod:ee:library:comments:enum:assertAction:map_Warn';
            map('error')='physmod:ee:library:comments:enum:assertAction:map_Error';
        end
    end
end
