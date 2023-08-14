classdef LinearPrelookupFunctionStrategy<handle




    methods
        function prelookupString=getPrelookupString(~,spacing,numInputs)
            prelookupString=convertStringsToChars(strings(numInputs,1));

            for i=1:numInputs
                if spacing==0
                    prelookupString{i}=FunctionApproximation.internal.prelookupfunction.StringForLinearEvenSpacingPrelookupFunction.getPrelookupString(i);
                elseif spacing==1
                    prelookupString{i}=FunctionApproximation.internal.prelookupfunction.StringForLinearEvenPow2SpacingPrelookupFunction.getPrelookupString(i);
                elseif spacing==2
                    prelookupString{i}=FunctionApproximation.internal.prelookupfunction.StringForLinearUnevenSpacingPrelookupFunction.getPrelookupString(i);
                end
            end
            prelookupString=[prelookupString{:}];
        end
    end
end
