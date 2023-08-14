classdef isCyclic<int32
    enumeration
        unique(1)
        cyclic(2)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('unique')='physmod:ee:library:comments:enum:isCyclic:map_Unique';
            map('cyclic')='physmod:ee:library:comments:enum:isCyclic:map_Cyclic';
        end
    end
end