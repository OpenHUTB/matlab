classdef gminParam<int32



    enumeration
        yes(0)
        no(1)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('yes')='physmod:ee:library:comments:enum:gminParam:map_Yes';
            map('no')='physmod:ee:library:comments:enum:gminParam:map_No';
        end
    end
end