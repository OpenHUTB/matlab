function[newNode,isSubsasgn]=reloadv1tov2(obj)






    isSubsasgn=true;



    if isa(obj.Operator,'optim.internal.problemdef.Subsref')

        sz=obj.Size;

        expr={obj.ExprLeft};

        forestIdx={1:prod(sz)};

        treeIdx={obj.Operator.OutLinIdx};

        newNode=optim.internal.problemdef.SubsasgnExpressionImpl(sz,forestIdx,expr,treeIdx);




        setId(newNode,obj.Id);
    elseif isa(obj.Operator,'optim.internal.problemdef.SubsasgnDelete')

        sz=obj.Size;

        lhs=obj.ExprLeft;
        expr={lhs};

        lhsSz=lhs.Size;


        linIdx=obj.Operator.OutLinIdx;
        newlinIdxloc=true(lhsSz);
        newlinIdxloc(linIdx)=false;
        lhsTreeIdx=find(newlinIdxloc);
        treeIdx={lhsTreeIdx};

        forestIdx={1:prod(sz)};

        newNode=optim.internal.problemdef.SubsasgnExpressionImpl(sz,forestIdx,expr,treeIdx);




        setId(newNode,obj.Id);
    elseif isa(obj.Operator,'optim.internal.problemdef.Reshape')

        sz=obj.Size;

        expr={obj.ExprLeft};



        treeIdx={':'};

        forestIdx={':'};

        newNode=optim.internal.problemdef.SubsasgnExpressionImpl(sz,forestIdx,expr,treeIdx);




        setId(newNode,obj.Id);
    else


        newNode=obj;
        newNode.UnaryExpressionImplVersion=2;
        isSubsasgn=false;
    end
