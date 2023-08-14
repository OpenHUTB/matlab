function storeNoSubsasgn(visitor,forestSize)





    [forestStr,numParens,isArgOrVar,isAllZeros]=pop(visitor);
    visitor.Head=visitor.Head-1;


    if isAllZeros
        pushAllZeros(visitor,forestSize);
        return;
    end


    forestName=visitor.ForestName;
    [forestStr,numParens,isArgOrVar,singleLine,forestBody]=visitor.reshapeInputStr(...
    forestName,forestSize,forestStr,numParens,isArgOrVar);


    addToExprBody(visitor,forestBody);
    push(visitor,forestStr,numParens,isArgOrVar,isAllZeros,singleLine);

end
