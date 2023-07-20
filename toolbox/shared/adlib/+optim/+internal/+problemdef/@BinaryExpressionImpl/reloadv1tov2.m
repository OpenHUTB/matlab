function[newNode,isSubsasgn]=reloadv1tov2(obj)






    isSubsasgn=true;


    if isa(obj.Operator,'optim.internal.problemdef.Subsasgn')

        sz=obj.Size;

        lhs=obj.ExprLeft;
        rhs=obj.ExprRight;

        lhsSz=lhs.Size;
        rhsSz=rhs.Size;

        linIdx=obj.Operator.OutLinIdx;

        if all(rhsSz==1)
            rhsTreeIdx=ones(1,numel(linIdx));
        else
            rhsTreeIdx=1:prod(rhsSz);
        end


        newlinIdxloc=true(prod(lhsSz),1);
        newlinIdxloc(linIdx)=false;
        lhsTreeIdx=find(newlinIdxloc);
        exprList={lhs,rhs};


        nDims=numel(lhsSz);
        lhsForestIdx=lhsTreeIdx;
        grownDims=find(sz(1:nDims-1)~=lhsSz(1:nDims-1));
        if any(grownDims)
            newLinIdx=optim.internal.problemdef.indexing.computeShiftedIdx(lhsSz,sz,grownDims);
            lhsForestIdx=newLinIdx(lhsForestIdx);
        end
        forestIdxList={lhsForestIdx,linIdx};
        treeIdxList={lhsTreeIdx,rhsTreeIdx};

        newNode=optim.internal.problemdef.SubsasgnExpressionImpl(sz,forestIdxList,exprList,treeIdxList);




        setId(newNode,obj.Id);
    elseif isa(obj.Operator,'optim.internal.problemdef.Concat')







        exprLeftSz=obj.Operator.LeftSize;
        exprRightSz=obj.Operator.RightSize;

        dim=obj.Operator.Dimension;

        outSize=exprLeftSz;
        outSize(dim)=exprLeftSz(dim)+exprRightSz(dim);

        exprLeft=obj.ExprLeft;
        exprRight=obj.ExprRight;

        exprList={exprLeft,exprRight};

        treeIdxList{2}=1:prod(exprRightSz);
        treeIdxList{1}=1:prod(exprLeftSz);



        nDims=numel(outSize);
        reorder=dim<nDims;

        if reorder





            firstProd=prod(outSize(1:dim-1));
            lastProd=prod(outSize(dim+1:end));

            shiftSize=[ones(1,dim),outSize(dim+1:end)];


            forestIdxList{1}=optim.internal.problemdef.indexing.computeShiftedIdx(exprLeftSz,outSize,dim,...
            firstProd,lastProd,shiftSize);



            forestIdxList{2}=prod(exprLeftSz(1:dim))+...
            optim.internal.problemdef.indexing.computeShiftedIdx(exprRightSz,outSize,dim,...
            firstProd,lastProd,shiftSize);

        else




            forestIdxList{1}=treeIdxList{1};
            forestIdxList{2}=prod(exprLeftSz(1:dim))+treeIdxList{2};

        end


        newNode=optim.internal.problemdef.SubsasgnExpressionImpl(outSize,forestIdxList,exprList,treeIdxList);




        setId(newNode,obj.Id);

    else


        newNode=obj;
        newNode.BinaryExpressionImplVersion=2;
        isSubsasgn=false;

    end
