classdef numberThrows<int32



    enumeration
        three(3)
        four(4)
        five(5)
        six(6)
        seven(7)
        eight(8)
    end

    methods(Static)
        function map=displayText()
            map=containers.Map;
            map('three')='3';
            map('four')='4';
            map('five')='5';
            map('six')='6';
            map('seven')='7';
            map('eight')='8';
        end
    end
end
