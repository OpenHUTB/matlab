classdef StringForLinearEvenPow2SpacingPrelookupFunction<FunctionApproximation.internal.prelookupfunction.StringForPrelookupFunction





    methods(Static)
        function prelookupString=getPrelookupString(inputNumber)
            prelookupString=['[index(',num2str(inputNumber),'),frac(',num2str(inputNumber),')] = preLookUp(inputValues',num2str(inputNumber),...
            '(i),breakpointValues',num2str(inputNumber),',idxType,fracType,bpSpaceExponent',num2str(inputNumber),',bpSpaceReciprocal',num2str(inputNumber),');',newline];
        end
    end
end


