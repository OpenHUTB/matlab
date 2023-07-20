function indexSearchString=getIndexSearchString(spacing,inputType)




    if spacing==0
        indexSearchString=FunctionApproximation.internal.indexsearchstring.EvenSpacingIndexSearchString.getSearchString();
    elseif spacing==1
        indexSearchString=FunctionApproximation.internal.indexsearchstring.EvenPowTwoSpacingIndexSearchString.getSearchString(inputType);
    else
        indexSearchString=FunctionApproximation.internal.indexsearchstring.BinaryIndexSearchString.getSearchString();
    end
end