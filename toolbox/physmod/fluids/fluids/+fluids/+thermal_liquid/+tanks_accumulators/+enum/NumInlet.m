classdef NumInlet<int32




    enumeration
        One(1)
        Two(2)
        Three(3)
        Four(4)
        Five(5)
        Six(6)
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
        end
    end
end