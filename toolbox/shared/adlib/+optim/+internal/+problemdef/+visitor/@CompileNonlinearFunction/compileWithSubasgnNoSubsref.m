function compileWithSubasgnNoSubsref(visitor,treeHeadIdx,forestIdxStr)








    forestStr=visitor.ForestName;


    treeIsAllZero=isChildAllZero(visitor,treeHeadIdx);

    if~treeIsAllZero






        addParens=0;
        treeFunStr=getChildArgumentName(visitor,treeHeadIdx,addParens);


        funStr=...
        forestStr+"("+forestIdxStr+")"+" = "+treeFunStr+";"+newline;
        addToExprBody(visitor,funStr);


        visitor.ForestIsAllZero=treeIsAllZero;
    end

end
