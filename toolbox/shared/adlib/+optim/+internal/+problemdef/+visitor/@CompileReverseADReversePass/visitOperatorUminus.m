function visitOperatorUminus(visitor,~,Node)





    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushJacAllZeros(visitor,numel(Node.ExprLeft));
        return;
    end





    addParens=1;
    [jacVarName,jacParens]=getParentJacArgumentName(visitor,addParens);


    leftJac="(-"+jacVarName+")";
    leftJacParens=jacParens+1;
    leftJacIsArgOrVar=false;
    leftJacIsAllZero=false;


    push(visitor,leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);

end
