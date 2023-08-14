function visitIndexingNode(visitor,visitTreeFun,forestSize,...
    nTrees,treeList,forestIndexList,treeIndexList)






    totalVar=visitor.TotalVar;
    nElem=prod(forestSize);


    Aval=sparse(totalVar,nElem);
    bval=zeros(nElem,1);



    for i=1:nTrees

        treei=treeList{i};


        treeHeadIdx=visitTreeFun(visitor,treei,i);
        [bi,Ai]=popChild(visitor,treeHeadIdx);



        forestIndex=forestIndexList{i};






        treeIndex=treeIndexList{i};




        if nnz(Ai)>0
            Aval(:,forestIndex)=Ai(:,treeIndex);%#ok<SPRIX> sparse column indexing is ok here
        end
        bval(forestIndex)=bi(treeIndex);
    end


    push(visitor,Aval,bval);

end
