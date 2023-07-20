function compileWithSubsasgnWithSubsref(visitor,treeHeadIdx,forestIdxStr,treeIdxStr)








    forestStr=visitor.ForestName;


    treeIsAllZero=isChildAllZero(visitor,treeHeadIdx);




    if~treeIsAllZero




        addParens=Inf;
        treeFunStr=getChildArgumentName(visitor,treeHeadIdx,addParens);


        funStr=...
        forestStr+"("+forestIdxStr+")"+...
        " = "+treeFunStr+"("+treeIdxStr+")"+";"+newline;
        addToExprBody(visitor,funStr);


        visitor.ForestIsAllZero=treeIsAllZero;
    end

end
