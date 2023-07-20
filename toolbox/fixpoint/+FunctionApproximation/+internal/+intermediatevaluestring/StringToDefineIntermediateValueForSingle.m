classdef StringToDefineIntermediateValueForSingle<FunctionApproximation.internal.intermediatevaluestring.StringToDefineIntermediateValue



    methods(Static)
        function string=getIntermediateValueString(~)
            string=['intermediateValue = cast(zeros(1,nargin),''like'',single([]));',newline];
        end
    end
end
