classdef with_neutral<int32




    enumeration
        no(1)
        yes(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('no')='physmod:ee:library:comments:enum:with_neutral:map_No';
            map('yes')='physmod:ee:library:comments:enum:with_neutral:map_Yes';
        end
    end
end
