classdef EvenSpacingIndexSearchString<FunctionApproximation.internal.indexsearchstring.IndexSearchString




    methods(Static)
        function searchString=getSearchString(~)
            searchString='idx(:) = floor((input-bpdata(1)).*(bpSpaceReciprocal));';
        end
    end
end
