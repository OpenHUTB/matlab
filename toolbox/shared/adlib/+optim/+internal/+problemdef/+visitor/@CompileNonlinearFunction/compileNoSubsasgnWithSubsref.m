function compileNoSubsasgnWithSubsref(visitor,treeHeadIdx,treeIdxStr)












    isAllZero=isChildAllZero(visitor,treeHeadIdx);
    if isAllZero


        pushAllZeros(visitor,1);
        return;
    end


    addParens=Inf;
    [treeFunStr,numParens]=...
    getChildArgumentName(visitor,treeHeadIdx,addParens);



    forestStr=treeFunStr+"("+treeIdxStr+")";
    numParens=numParens+1;
    isArgOrVar=false;
    singleLine=true;


    push(visitor,forestStr,numParens,isArgOrVar,isAllZero,singleLine);
end
