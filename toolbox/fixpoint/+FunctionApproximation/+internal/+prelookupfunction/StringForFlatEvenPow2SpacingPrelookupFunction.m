classdef StringForFlatEvenPow2SpacingPrelookupFunction<FunctionApproximation.internal.prelookupfunction.StringForPrelookupFunction





    methods(Static)
        function prelookupString=getPrelookupString(inputNumber)
            prelookupString=['index(',num2str(inputNumber),') = preLookUpIndexOnly(inputValues',num2str(inputNumber),...
            '(i),breakpointValues',num2str(inputNumber),',idxType,bpSpaceExponent',num2str(inputNumber),',bpSpaceReciprocal',num2str(inputNumber),');',newline];
        end
    end
end


