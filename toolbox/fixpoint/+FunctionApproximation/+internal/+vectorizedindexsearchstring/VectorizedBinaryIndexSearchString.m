classdef VectorizedBinaryIndexSearchString<FunctionApproximation.internal.indexsearchstring.IndexSearchString




    methods(Static)
        function searchString=getSearchString(~)
            searchString=['idxLeft = ones(size(input));',newline,...
            'idxRight = length(bpdata) * ones(size(input));',newline,...
            'idxMiddle = ones(size(input));',newline,...
            'flag = true(size(input));',newline,newline,...
            'while any(flag)',newline,...
            'idxMiddle(:) = idxLeft + floor((idxRight - idxLeft)/2);',newline,...
            'idxTemp = input < bpdata(idxMiddle);',newline,...
            'idxRight(idxTemp & flag) = idxMiddle(idxTemp & flag);',newline,...
            'idxLeft(~idxTemp & flag) = idxMiddle(~idxTemp & flag);',newline,...
            'flag = idxLeft < idxRight-1;',newline,...
            'end',newline,newline,...
            'idx(:) = idxLeft;',newline,newline];
        end
    end
end


