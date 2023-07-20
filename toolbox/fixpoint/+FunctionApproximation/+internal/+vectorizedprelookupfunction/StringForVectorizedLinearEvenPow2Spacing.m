classdef StringForVectorizedLinearEvenPow2Spacing<FunctionApproximation.internal.prelookupfunction.StringForPrelookupFunction





    methods(Static)
        function prelookupString=getPrelookupString(inputNumber)
            prelookupString=['breakpointValues',num2str(inputNumber),' = reshape(breakpointValues',num2str(inputNumber),',[],1);',newline,...
            '[index(:,',num2str(inputNumber),'),frac(:,',num2str(inputNumber),')] = preLookUp(inputValues',num2str(inputNumber),...
            ',breakpointValues',num2str(inputNumber),',idxType,fracType,bpSpaceExponent',num2str(inputNumber),',bpSpaceReciprocal',num2str(inputNumber),');',newline];
        end
    end
end


