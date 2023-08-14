classdef NumElements<int32





    enumeration
        Two(2)
        Three(3)
        Four(4)
        Five(5)
        Six(6)
        Seven(7)
        Eight(8)
        Nine(9)
        Ten(10)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Two')='2';
            map('Three')='3';
            map('Four')='4';
            map('Five')='5';
            map('Six')='6';
            map('Seven')='7';
            map('Eight')='8';
            map('Nine')='9';
            map('Ten')='10';
        end
    end

end