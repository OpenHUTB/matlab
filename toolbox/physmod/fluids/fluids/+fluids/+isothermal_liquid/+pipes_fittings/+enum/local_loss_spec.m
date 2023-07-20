classdef local_loss_spec<int32




    enumeration
        aggregate_length(1)
        loss_coefficient(2)
    end

    methods(Static,Hidden)
        function map=displayText()
            map=containers.Map;
            map('aggregate_length')='Aggregate equivalent length';
            map('loss_coefficient')='Local loss coefficient';
        end
    end
end