classdef BinaryIndexSearchString<FunctionApproximation.internal.indexsearchstring.IndexSearchString




    methods(Static)
        function searchString=getSearchString(~)
            searchString=['while (idxRight-idxLeft > 1)',newline,'idxMiddle(:) = (idxLeft+idxRight)/2;',...
            newline,'if input < bpdata(idxMiddle)',newline,'idxRight(:) = idxMiddle;',...
            newline,'else',newline,'idxLeft(:) = idxMiddle;',newline,'end',newline,...
            'end',newline,'idx(:) = idxLeft;'];
        end
    end
end
