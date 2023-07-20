classdef repeatability<int32





    enumeration
        notRepeatable(1)
        repeatable(2)
        specifySeed(3)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('notRepeatable')='physmod:ee:library:comments:enum:ic:repeatability:map_NotRepeatable';
            map('repeatable')='physmod:ee:library:comments:enum:ic:repeatability:map_Repeatable';
            map('specifySeed')='physmod:ee:library:comments:enum:ic:repeatability:map_SpecifySeed';
        end
    end
end