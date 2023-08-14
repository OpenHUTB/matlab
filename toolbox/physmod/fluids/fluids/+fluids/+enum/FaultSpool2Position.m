classdef FaultSpool2Position<int32




    enumeration
        Negative(-1)
        Positive(1)
        Last(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('Negative')='Negative';
            map('Positive')='Positive';
            map('Last')='Maintain last value';
        end
    end
end