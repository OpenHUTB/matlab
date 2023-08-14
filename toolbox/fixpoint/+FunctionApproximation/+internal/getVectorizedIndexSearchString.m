function indexSearchString=getVectorizedIndexSearchString(spacing,inputType)




    if spacing==0
        indexSearchString=FunctionApproximation.internal.vectorizedindexsearchstring.VectorizedEvenSpacingIndexSearchString.getSearchString();
    elseif spacing==1
        indexSearchString=FunctionApproximation.internal.vectorizedindexsearchstring.VectorizedEvenPowTwoSpacingIndexSearchString.getSearchString(inputType);
    else
        indexSearchString=FunctionApproximation.internal.vectorizedindexsearchstring.VectorizedBinaryIndexSearchString.getSearchString();
    end
end