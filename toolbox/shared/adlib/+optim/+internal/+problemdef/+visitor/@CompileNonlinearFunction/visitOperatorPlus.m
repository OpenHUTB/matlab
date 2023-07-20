function visitOperatorPlus(visitor,op,Node)





    leftAllZero=isChildAllZero(visitor,1);
    rightAllZero=isChildAllZero(visitor,2);

    if leftAllZero
        if rightAllZero

            pushAllZeros(visitor,size(Node));
        else

            childIdx=2;
            compileScalarExpansion(visitor,childIdx,Node.ExprRight,Node.ExprLeft);
        end
    elseif rightAllZero

        childIdx=1;
        compileScalarExpansion(visitor,childIdx,Node.ExprLeft,Node.ExprRight);
    else

        compileOperator(visitor,op,Node);
    end

end
