function visitIndexingNode(visitor,visitTreeFun,forestSize,...
    nTrees,treeList,forestIndexList,treeIndexList)






    types=zeros(1,nTrees);
    vals=cell(1,nTrees);


    for i=nTrees:-1:1

        treei=treeList{i};


        treeHeadIdx=visitTreeFun(visitor,treei,i);
        [types(i),vals{i}]=popChild(visitor,treeHeadIdx);
    end


    storeIndexingData(visitor,forestSize,nTrees,forestIndexList,treeIndexList,types,vals);

end
