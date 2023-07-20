function compileNoSubasgnNoSubsref(visitor,treeHeadIdx)








    [treeFunStr,numParens,isArgOrVar,isAllZero,singleLine]=popChild(visitor,treeHeadIdx);

    if singleLine




        forestStr=treeFunStr;
        treeBody="";
    else



        forestStr=visitor.ForestName;
        numParens=0;
        isArgOrVar=true;
        singleLine=true;
        treeBody=sprintf(treeFunStr,forestStr)+newline;
    end


    addToExprBody(visitor,treeBody);
    push(visitor,forestStr,numParens,isArgOrVar,isAllZero,singleLine);

end
