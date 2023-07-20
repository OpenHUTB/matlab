function storeWithSubsasgn(visitor,forestSize)





    forestStr=visitor.ForestName;
    numParens=0;
    isArgOrVar=true;
    isAllZeros=visitor.ForestIsAllZero;


    if isAllZeros
        pushAllZeros(visitor,forestSize);
        return;
    end


    zeroStr=...
    optim.internal.problemdef.ZeroExpressionImpl.getNonlinearStr(forestSize);
    initStr=forestStr+" = "+zeroStr+";"+newline;
    prependToExprBody(visitor,initStr);


    [forestStr,numParens,isArgOrVar,singleLine,forestBody]=visitor.reshapeInputStr(...
    forestStr,forestSize,forestStr,numParens,isArgOrVar);


    addToExprBody(visitor,forestBody);
    push(visitor,forestStr,numParens,isArgOrVar,isAllZeros,singleLine);

end
