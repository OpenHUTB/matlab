classdef num_inlet<int32




    enumeration
        one(1)
        two(2)
        three(3)
        four(4)
        five(5)
        six(6)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('one')='1';
            map('two')='2';
            map('three')='3';
            map('four')='4';
            map('five')='5';
            map('six')='6';
        end
    end
end