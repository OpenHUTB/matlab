classdef VectorizedNearestPrelookupFunctionStrategy<handle




    methods
        function prelookupString=getPrelookupString(~,spacing,numInputs)
            prelookupString=convertStringsToChars(strings(numInputs,1));

            for i=1:numInputs
                if spacing==0
                    prelookupString{i}=FunctionApproximation.internal.vectorizedprelookupfunction.StringForVectorizedNearestEvenSpacing.getPrelookupString(i);
                elseif spacing==1
                    prelookupString{i}=FunctionApproximation.internal.vectorizedprelookupfunction.StringForVectorizedNearestEvenPow2Spacing.getPrelookupString(i);
                elseif spacing==2
                    prelookupString{i}=FunctionApproximation.internal.vectorizedprelookupfunction.StringForVectorizedNearestUnevenSpacing.getPrelookupString(i);
                end
            end
            prelookupString=['tableValues = reshape(tableValues,[],1);',newline,prelookupString{:}];
        end
    end
end
