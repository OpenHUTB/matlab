classdef pH<int32
    enumeration
        constant(0)
        dynamic(1)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('constant')='physmod:ee:library:comments:enum:electrolyzer:pH:map_Constant';
            map('dynamic')='physmod:ee:library:comments:enum:electrolyzer:pH:map_Dynamic';
        end
    end
end
