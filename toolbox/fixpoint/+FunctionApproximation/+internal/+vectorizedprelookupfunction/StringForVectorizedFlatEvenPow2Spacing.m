classdef StringForVectorizedFlatEvenPow2Spacing<FunctionApproximation.internal.prelookupfunction.StringForPrelookupFunction





    methods(Static)
        function prelookupString=getPrelookupString(inputNumber)
            prelookupString=['breakpointValues',num2str(inputNumber),' = reshape(breakpointValues',num2str(inputNumber),',[],1);',newline,...
            'index(:,',num2str(inputNumber),') = preLookUpIndexOnly(inputValues',num2str(inputNumber),...
            ',breakpointValues',num2str(inputNumber),',idxType,bpSpaceExponent',num2str(inputNumber),',bpSpaceReciprocal',num2str(inputNumber),');',newline];
        end
    end
end


