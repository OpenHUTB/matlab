classdef NumOrifices<int32





    enumeration
        One(1)
        Two(2)
        Three(3)
        Four(4)
        Five(5)
        Six(6)
        Seven(7)
        Eight(8)
        Nine(9)
        Ten(10)
        Eleven(11)
        Twelve(12)
        Thirteen(13)
        Fourteen(14)
        Fifteen(15)
        Sixteen(16)
        Seventeen(17)
        Eighteen(18)
        Nineteen(19)
        Twenty(20)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('One')='1';
            map('Two')='2';
            map('Three')='3';
            map('Four')='4';
            map('Five')='5';
            map('Six')='6';
            map('Seven')='7';
            map('Eight')='8';
            map('Nine')='9';
            map('Ten')='10';
            map('Eleven')='11';
            map('Twelve')='12';
            map('Thirteen')='13';
            map('Fourteen')='14';
            map('Fifteen')='15';
            map('Sixteen')='16';
            map('Seventeen')='17';
            map('Eighteen')='18';
            map('Nineteen')='19';
            map('Twenty')='20';
        end
    end

end