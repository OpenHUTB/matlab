function[indexingStr,numParens,compact]=getIndexingString(idx,contiguous)

























    respectOrientation=false;


    expandNonCompact=true;


    [indexingStr,numParens,compact]=...
    optim.internal.problemdef.compile.getVectorString(idx,contiguous,respectOrientation,expandNonCompact);
