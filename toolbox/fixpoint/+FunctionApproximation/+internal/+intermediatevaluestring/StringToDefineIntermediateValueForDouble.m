classdef StringToDefineIntermediateValueForDouble<FunctionApproximation.internal.intermediatevaluestring.StringToDefineIntermediateValue



    methods(Static)
        function string=getIntermediateValueString(~)
            string=['intermediateValue = cast(zeros(1,nargin),''like'',double([]));',newline];
        end
    end
end
