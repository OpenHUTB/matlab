classdef VectorizedEvenPowTwoSpacingIndexSearchString<FunctionApproximation.internal.indexsearchstring.IndexSearchString




    methods(Static)
        function searchString=getSearchString(inputType)
            if any(arrayfun(@isfloat,inputType))
                searchString=['idx(:) = floor((input-bpdata(1)).*(bpSpaceReciprocal));',newline,...
                'idx(:) = idx + 1;';];
            elseif any(arrayfun(@isscalingbinarypoint,inputType))
                wordLength=zeros(1,numel(inputType));
                fracLength=zeros(1,numel(inputType));
                sign=zeros(1,numel(inputType));
                for i=1:numel(inputType)
                    fracLength(i)=inputType(i).FractionLength;
                    wordLength(i)=inputType(i).WordLength;
                    sign(i)=inputType(i).Signed;
                end
                tmpString=['tmp = fi(input-bpdata(1),',num2str(sign(true)),',',...
                num2str(max(max(wordLength),32)),',',num2str(max(fracLength)),');'];
                searchString=[tmpString,newline,'idx(:) = floor(bitshift(tmp,bpSpaceExponent));',newline,...
                'idx(:) = idx + 1;'];
            else
                for i=1:numel(inputType)
                    bpShiftString='bp0 = bitshift(bpdata(1),bpSpaceExponent);';
                end
                searchString=[bpShiftString,newline,'idx(:) = floor((input - bp0) .* (bpSpaceReciprocal));',newline,...
                'idx(:) = idx + 1;'];
            end
        end
    end
end


