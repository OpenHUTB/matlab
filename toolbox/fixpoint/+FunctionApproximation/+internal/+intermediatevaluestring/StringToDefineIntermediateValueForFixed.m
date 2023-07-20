classdef StringToDefineIntermediateValueForFixed<FunctionApproximation.internal.intermediatevaluestring.StringToDefineIntermediateValue



    methods(Static)
        function string=getIntermediateValueString(intermediateType)

            if intermediateType.isscalingslopebias
                string=['intermediateValue = cast(zeros(1,nargin),''like'',',intermediateType.tostring,');',newline];
            else
                string=['intermediateValue = cast(zeros(1,nargin),''like'',fi([],',intermediateType.tostring,'));',newline];
            end
        end
    end
end


