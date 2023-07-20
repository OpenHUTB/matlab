classdef NDLogicStringForFlatNearestFixedSlopeBias<handle





    methods(Static)
        function string=getInterpolationLogicString()
            string=['bpIdx = double(index-1) * stride'' + 1;',newline,...
            'if bpIdx >= numel(tableValues)',newline,...
            'output(i) = tableValues(end);',newline,...
            'else',newline,...
            'output(i) = tableValues(bpIdx);',newline,...
            'end'];
        end
    end
end


