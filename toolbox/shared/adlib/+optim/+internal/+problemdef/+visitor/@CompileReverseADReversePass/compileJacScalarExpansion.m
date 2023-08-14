function compileJacScalarExpansion(visitor,childIdx,thisNode,otherNode,...
    jacStr,jacParens,jacIsArgOrVar,jacIsAllZero)








    if isscalar(thisNode)&&~isscalar(otherNode)





        addParens=1;
        singleLine=true;
        [jacStr,jacParens,argBody]=addParensToArg(visitor,...
        jacStr,jacParens,jacIsArgOrVar,singleLine,addParens);
        visitor.ExprBody=visitor.ExprBody+argBody;
        jacStr="sum("+jacStr+",1)";
        jacParens=jacParens+1;
        jacIsArgOrVar=false;
    end

    pushChild(visitor,childIdx,jacStr,jacParens,jacIsArgOrVar,jacIsAllZero);