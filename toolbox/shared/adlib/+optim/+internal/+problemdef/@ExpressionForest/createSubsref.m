function createSubsref(obj,expr,linIdx,outSize)











    if isempty(linIdx)

        createZeros(obj,outSize);
    elseif expr.SingleTreeSpansAllIndices

        obj.TreeList=expr.TreeList;
        forestIndexList=1:numel(linIdx);
        obj.ForestIndexList={forestIndexList};
        obj.TreeIndexList={linIdx};
        obj.NumTrees=1;
        obj.SingleTreeSpansAllIndices=false;
        obj.Size=outSize;
        obj.Variables=expr.Variables;
    else
        nTrees=expr.NumTrees;


        keepTrees=false(nTrees,1);
        sz=expr.Size;
        forestIndexList=expr.ForestIndexList;
        treeIndexList=expr.TreeIndexList;

        treeIdxAtForestIdx=zeros(sz);
        for i=1:nTrees

            OrigForestIdx=forestIndexList{i};
            treeIdxAtForestIdx(OrigForestIdx)=treeIndexList{i};

            treeIdxInLinIdx=treeIdxAtForestIdx(linIdx);


            keepIdxInTreei=treeIdxInLinIdx~=0;
            if any(keepIdxInTreei)
                keepTrees(i)=true;


                forestIndexList{i}=find(keepIdxInTreei);
                treeIndexList{i}=treeIdxInLinIdx(keepIdxInTreei);
            end

            treeIdxAtForestIdx(OrigForestIdx)=0;
        end

        obj.TreeList=expr.TreeList(keepTrees);
        obj.ForestIndexList=forestIndexList(keepTrees);
        obj.TreeIndexList=treeIndexList(keepTrees);
        obj.NumTrees=sum(keepTrees);
        obj.SingleTreeSpansAllIndices=false;
        obj.Size=outSize;
        if~all(keepTrees)


            obj.Variables=computeVariables(obj);
        else

            obj.Variables=expr.Variables;
        end
    end

end