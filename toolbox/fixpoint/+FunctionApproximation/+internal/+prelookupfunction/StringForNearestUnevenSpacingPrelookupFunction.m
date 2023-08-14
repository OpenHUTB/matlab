classdef StringForNearestUnevenSpacingPrelookupFunction<FunctionApproximation.internal.prelookupfunction.StringForPrelookupFunction





    methods(Static)
        function prelookupString=getPrelookupString(inputNumber)
            prelookupString=['index(',num2str(inputNumber),') = preLookUpIndexOnly(inputValues',num2str(inputNumber),...
            '(i),breakpointValues',num2str(inputNumber),',idxType);',newline,...
            'if (index(',num2str(inputNumber),') < length(breakpointValues',num2str(inputNumber),...
            ')) && (accumneg(breakpointValues',num2str(inputNumber),'(index(',num2str(inputNumber),')+1),inputValues',num2str(inputNumber),...
            '(i)) <= accumneg(inputValues',num2str(inputNumber),'(i),breakpointValues',num2str(inputNumber),'(index(',num2str(inputNumber),'))))',newline,...
            'index(',num2str(inputNumber),') = cast((index(',num2str(inputNumber),') + 1),''like'',idxType);',newline,...
            'end',newline];
        end
    end
end


