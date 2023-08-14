function visitIndexingNode(visitor,visitTreeFun,forestSize,...
    nTrees,treeList,forestIndexList,treeIndexList)





    if nTrees==0


        pushAllZeroNode(visitor,forestSize);
        visitor.TreeStr=strings(prod(forestSize),1);
        return;
    end


    prevName=visitor.ForestName;
    prevAllZero=visitor.ForestIsAllZero;
    prevBody=visitor.ExprBody;


    visitor.ForestName="arg"+visitor.getNumArgs();
    visitor.ExprBody="";


    dosubs=visitor.doSubsasgn(nTrees,forestIndexList,forestSize);

    compileTreeFunction=@compileNoSubsasgn;
    storeForestFunction=@storeNoSubsasgn;

    if dosubs
        compileTreeFunction=@compileWithSubsasgn;
        storeForestFunction=@storeWithSubsasgn;
    end




    canDisplayEntrywise=visitor.ForDisplay;

    treeStr=strings(prod(forestSize),1);



    for i=1:nTrees

        treei=treeList{i};


        treeHeadIdx=visitTreeFun(visitor,treei,i);



        forestIndex=forestIndexList{i};






        treeIndex=treeIndexList{i};


        compileTreeFunction(visitor,treei,treeHeadIdx,forestIndex,treeIndex);



        prevBody=prevBody+visitor.ExprBody;
        visitor.ExprBody="";



        canDisplayEntrywise=canDisplayEntrywise&&~isempty(visitor.TreeStr);
        if canDisplayEntrywise

            treeStr(forestIndex)=visitor.TreeStr(treeIndex);
        end
    end
    visitor.ExprBody=prevBody;

    if canDisplayEntrywise

        visitor.TreeStr=treeStr;
    else

        visitor.TreeStr=[];
    end


    storeForestFunction(visitor,forestSize);


    visitor.ForestName=prevName;
    visitor.ForestIsAllZero=prevAllZero;

end
