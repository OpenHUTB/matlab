function visitOperatorMinus(visitor,op,Node)





    leftAllZero=isChildAllZero(visitor,1);
    rightAllZero=isChildAllZero(visitor,2);

    if leftAllZero
        if rightAllZero

            pushAllZeros(visitor,size(Node));
        else

            childIdx=2;
            compileScalarExpansion(visitor,childIdx,Node.ExprRight,Node.ExprLeft);


            addParens=1;
            [varName,numParens]=getArgumentName(visitor,addParens);
            visitor.Head=visitor.Head-1;

            funStr="(-"+varName+")";
            numParens=numParens+1;
            isArgOrVar=false;
            isAllZero=false;
            singleLine=true;
            push(visitor,funStr,numParens,isArgOrVar,isAllZero,singleLine);
        end
    elseif rightAllZero

        childIdx=1;
        compileScalarExpansion(visitor,childIdx,Node.ExprLeft,Node.ExprRight);
    else

        compileOperator(visitor,op,Node);
    end

end
