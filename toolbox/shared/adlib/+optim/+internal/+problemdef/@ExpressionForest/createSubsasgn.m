function createSubsasgn(obj,exprLHS,linIdx,exprRHS,outSize)














    if isempty(linIdx)

        copy(obj,exprLHS);
        obj.Size=outSize;
    else



        [newlinIdx,rhsIdx]=unique(linIdx,'last');



        if numel(newlinIdx)<numel(linIdx)
            linIdx=newlinIdx;
            if isscalar(exprRHS)

                rhsIdx=ones(1,numel(linIdx));
            end
            newExprRHS=optim.internal.problemdef.ExpressionForest;
            createSubsref(newExprRHS,exprRHS,rhsIdx,[1,numel(linIdx)]);
            exprRHS=newExprRHS;
        end



        if exprRHS.SingleTreeSpansAllIndices
            forestIndexList={linIdx};
            if isscalar(exprRHS)
                treeIndexList={ones(1,numel(linIdx))};
            else
                treeIndexList={1:numel(exprRHS)};
            end
        else
            forestIndexList=exprRHS.ForestIndexList;
            treeIndexList=exprRHS.TreeIndexList;
            numRHSTrees=exprRHS.NumTrees;
            if numRHSTrees==1
                forestIndexList={linIdx};
                if isscalar(exprRHS)
                    treeIndexList={treeIndexList{1}*ones(1,numel(linIdx))};
                end
            elseif numRHSTrees>0


                linIdxRs=reshape(linIdx,size(exprRHS));
                for i=1:numRHSTrees
                    idx=linIdxRs(forestIndexList{i});
                    forestIndexList{i}=idx(:);
                end
            end
        end


        inNelem=numel(exprLHS);


        keepIdx=true(inNelem,1);
        keepIdx(linIdx)=false;

        if~any(keepIdx)


            obj.TreeList=exprRHS.TreeList;
            obj.ForestIndexList=forestIndexList;
            obj.TreeIndexList=treeIndexList;
            obj.NumTrees=exprRHS.NumTrees;
            obj.SingleTreeSpansAllIndices=false;
            obj.Size=outSize;
            obj.Variables=exprRHS.Variables;
        else



            copy(obj,exprLHS);



            adjustLinIdx(obj,outSize);



            obj.Size=outSize;
            SubsasgnDeleteIdx(obj,linIdx);


            obj.TreeList=[obj.TreeList,exprRHS.TreeList];
            obj.ForestIndexList=[obj.ForestIndexList,forestIndexList];
            obj.TreeIndexList=[obj.TreeIndexList,treeIndexList];
            obj.NumTrees=obj.NumTrees+exprRHS.NumTrees;
            obj.SingleTreeSpansAllIndices=false;
            obj.Variables=optim.internal.problemdef.HashMapFunctions.union(...
            obj.Variables,exprRHS.Variables,'OptimizationExpression');
        end
    end

end


function adjustLinIdx(obj,outSize)





    inSize=obj.Size;
    nDims=numel(inSize);
    grownDims=find(outSize(1:nDims-1)~=inSize(1:nDims-1));



    if obj.SingleTreeSpansAllIndices
        idxList={1:numel(obj)};
        forestIndexList=idxList;
        obj.TreeIndexList=idxList;
        obj.SingleTreeSpansAllIndices=false;
    else
        forestIndexList=obj.ForestIndexList;
    end


    if any(grownDims)

        newLinIdx=optim.internal.problemdef.indexing.computeShiftedIdx(inSize,outSize,grownDims);

        for i=1:obj.NumTrees
            idx=newLinIdx(forestIndexList{i});
            forestIndexList{i}=idx(:);
        end
    end

    obj.ForestIndexList=forestIndexList;
end
