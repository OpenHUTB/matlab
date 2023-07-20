classdef num_supports<int32

    enumeration
        two(2)
        three(3)
        four(4)
    end
    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('two')='2';
            map('three')='3';
            map('four')='4';
        end
    end
end



