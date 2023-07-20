function storeIndexingData(visitor,forestSize,nTrees,...
    forestIndexList,treeIndexList,types,vals,canAD)





    storeIndexingData@optim.internal.problemdef.visitor.ComputeType(visitor,...
    forestSize,nTrees,forestIndexList,treeIndexList,types,vals);


    canAD=all(canAD,'all');
    pushProperties(visitor,forestSize,canAD);

end
