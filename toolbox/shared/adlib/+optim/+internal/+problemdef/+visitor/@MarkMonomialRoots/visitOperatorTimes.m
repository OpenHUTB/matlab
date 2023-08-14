function visitOperatorTimes(visitor,~,Node)





    curNodeIdx=visitor.CurNodeIdx;
    monomialFactor=visitor.MonomialFactor;
    isMonomialRoot=visitor.IsMonomialRoot;




    childIdx=getChildrenIndices(Node,curNodeIdx);
    leftNode=Node.ExprLeft;
    rightNode=Node.ExprRight;
    if isequal(leftNode.Size,[1,1])&&...
        isa(leftNode,'optim.internal.problemdef.NumericExpressionImpl')

        constNode=leftNode;
        addChildIdx=childIdx(2);
    elseif isequal(rightNode.Size,[1,1])&&...
        isa(rightNode,'optim.internal.problemdef.NumericExpressionImpl')

        constNode=rightNode;
        addChildIdx=childIdx(1);
    else


        return;
    end

    isMonomialRoot(addChildIdx)=true;
    fac=monomialFactor(curNodeIdx);
    monomialFactor(addChildIdx)=fac.*constNode.Value;

    isMonomialRoot(curNodeIdx)=false;
    monomialFactor(curNodeIdx)=NaN;


    visitor.MonomialFactor=monomialFactor;
    visitor.IsMonomialRoot=isMonomialRoot;

end