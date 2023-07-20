function visitIndexingNode(visitor,visitTreeFun,forestSize,...
    nTrees,treeList,forestIndexList,treeIndexList)






    prevJacName=visitor.ForestJacName;
    prevJacIsAllZero=visitor.ForestJacIsAllZero;
    prevJacBody=visitor.ExprAndJacBody;


    visitor.ForestJacName="arg"+visitor.getNumArgs();
    visitor.ExprAndJacBody="";

    visitIndexingNode@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,...
    visitTreeFun,forestSize,nTrees,treeList,forestIndexList,treeIndexList);


    visitor.ExprAndJacBody=prevJacBody+visitor.ExprAndJacBody;
    visitor.ForestJacName=prevJacName;
    visitor.ForestJacIsAllZero=prevJacIsAllZero;

end
