function compileJacScalarExpansion(visitor,childIdx,thisNode,otherNode)








    if isscalar(thisNode)&&~isscalar(otherNode)
        addParens=2;
        [jacName,jacParens]=getChildJacArgumentName(visitor,childIdx,addParens);
        sizeStr=string(numel(otherNode));
        jacStr="repmat("+jacName+", 1, "+sizeStr+")";
        jacParens=jacParens+2;
        jacIsArgOrVar=false;
        jacIsAllZero=false;
        pushJac(visitor,jacStr,jacParens,jacIsArgOrVar,jacIsAllZero);
    else
        [jacName,jacParens,jacIsArgOrVar,jacIsAllZero]=...
        popChildJac(visitor,childIdx);
        pushJac(visitor,jacName,jacParens,jacIsArgOrVar,jacIsAllZero);
    end

end