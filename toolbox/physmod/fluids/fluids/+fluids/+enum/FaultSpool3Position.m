classdef FaultSpool3Position<int32




    enumeration
        Negative(-1)
        Neutral(0)
        Positive(1)
        Last(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Negative')='Negative';
            map('Neutral')='Neutral';
            map('Positive')='Positive';
            map('Last')='Maintain last value';
        end
    end
end