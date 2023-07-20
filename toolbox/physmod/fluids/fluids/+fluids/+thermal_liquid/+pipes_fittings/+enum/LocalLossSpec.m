classdef LocalLossSpec<int32




    enumeration
        AggregateLength(1)
        LossCoefficient(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('AggregateLength')='Aggregate equivalent length';
            map('LossCoefficient')='Local loss coefficient';
        end
    end
end