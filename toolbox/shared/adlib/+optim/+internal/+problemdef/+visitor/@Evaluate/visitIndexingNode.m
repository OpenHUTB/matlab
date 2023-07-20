function visitIndexingNode(visitor,visitTreeFun,forestSize,...
    nTrees,treeList,forestIndexList,treeIndexList)






    nElem=prod(forestSize);


    val=zeros(nElem,1);



    for i=1:nTrees

        treei=treeList{i};


        treeHeadIdx=visitTreeFun(visitor,treei,i);
        treeHead=visitor.ChildrenHead(treeHeadIdx);
        vali=visitor.Value{treeHead};



        forestIndex=forestIndexList{i};






        treeIndex=treeIndexList{i};


        val(forestIndex)=vali(treeIndex);
    end

    val=reshape(val,forestSize);


    push(visitor,val);

end
