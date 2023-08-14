classdef VectorizedEvenSpacingIndexSearchString<FunctionApproximation.internal.indexsearchstring.IndexSearchString




    methods(Static)
        function searchString=getSearchString(~)
            searchString=['idx(:) = floor((input-bpdata(1)).*(bpSpaceReciprocal));',newline,...
            'idx(:) = idx + 1;'];
        end
    end
end


