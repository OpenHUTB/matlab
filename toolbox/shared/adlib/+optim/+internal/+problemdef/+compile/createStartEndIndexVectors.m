function idxVector=createStartEndIndexVectors(sizeOfObjects)





    endIdx=cumsum(sizeOfObjects);
    endIdx=endIdx(:);
    startIdx=endIdx(1:end-1)+1;
    startIdx=[1;startIdx];

    idxVector.Start=startIdx;
    idxVector.End=endIdx;
