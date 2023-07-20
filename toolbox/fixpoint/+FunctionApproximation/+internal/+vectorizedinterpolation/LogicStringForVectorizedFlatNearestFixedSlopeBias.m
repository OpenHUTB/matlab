classdef LogicStringForVectorizedFlatNearestFixedSlopeBias<handle




    methods(Static)
        function string=getInterpolationLogicString(numInputs)
            string=['index(index>=numel(tableValues)) = numel(tableValues);',newline,...
            'output(:) = tableValues(index);'];

            if numInputs>1
                string=['bpIdx = double(index-1) * stride'' + 1;',newline,...
                'bpIdx(bpIdx >= numel(tableValues)) = numel(tableValues);',newline,...
                'output(:) = tableValues(bpIdx);'];
            end
        end
    end
end


