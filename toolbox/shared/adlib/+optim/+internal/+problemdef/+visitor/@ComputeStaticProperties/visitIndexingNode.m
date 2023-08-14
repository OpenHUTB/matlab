function visitIndexingNode(visitor,visitTreeFun,forestSize,...
    nTrees,treeList,forestIndexList,treeIndexList)






    types=zeros(1,nTrees);
    canAD=true(1,nTrees);
    vals=cell(1,nTrees);

    for i=1:nTrees

        treei=treeList{i};


        treeHeadIdx=visitTreeFun(visitor,treei,i);
        [types(i),vals{i},sizei,canAD(i)]=popChild(visitor,treeHeadIdx);



        if~all(sizei==1)&&~isequal(prod(sizei),numel(forestIndexList{i}))


            error('shared_adlib:static:SizeChangeDetected','The size of the LHS must not change');
        end
    end


    storeIndexingData(visitor,forestSize,nTrees,forestIndexList,treeIndexList,types,vals,canAD);

end
