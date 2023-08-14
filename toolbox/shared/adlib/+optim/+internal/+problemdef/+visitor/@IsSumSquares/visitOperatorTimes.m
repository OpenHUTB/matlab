function visitOperatorTimes(visitor,~,Node)





    leftNode=Node.ExprLeft;
    rightNode=Node.ExprRight;

    if isequal(leftNode.Size,[1,1])&&...
        isa(leftNode,'optim.internal.problemdef.NumericExpressionImpl')


        factori=leftNode.Value;
        if factori<0


            visitor.ISS=false;
            return;
        else


            visitor.CurrentFactor=visitor.CurrentFactor.*sqrt(factori);

            currentNodeIdx=visitor.CurrentNodeIdx-Node.StackLength+Node.ChildrenPosition(2);
        end
    elseif isequal(rightNode.Size,[1,1])&&...
        isa(rightNode,'optim.internal.problemdef.NumericExpressionImpl')


        factori=rightNode.Value;
        if factori<0


            visitor.ISS=false;
            return;
        else


            visitor.CurrentFactor=visitor.CurrentFactor.*sqrt(factori);

            currentNodeIdx=visitor.CurrentNodeIdx-Node.StackLength+Node.ChildrenPosition(1);
        end
    else


        visitor.ISS=false;
        return;
    end


    visitor.CurrentNodeIdx=currentNodeIdx;
    Node=visitor.Stack{currentNodeIdx};
    acceptVisitor(Node,visitor);

end
