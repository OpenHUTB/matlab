function visitOperatorProd(visitor,op,Node)





    leftVarName=getForwardMemory(visitor);


    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushJacAllZeros(visitor,numel(Node.ExprLeft));
        return;
    end


    dimi=op.Dimension;



    addParens=1;


    [jacVarName,jacParens]=getParentJacArgumentName(visitor,addParens);


    [leftJacStr,leftJacParens]=...
    optim.internal.problemdef.visitor.CompileForwardAD.createProdJacobianString(...
    Node.ExprLeft,leftVarName,dimi);


    if strcmp(dimi,"all")
        leftJac="("+jacVarName+" * "+leftJacStr+")";
    else
        leftJac="("+leftJacStr+" * "+jacVarName+")";
    end
    leftJacIsArgOrVar=false;
    leftJacIsAllZero=false;


    leftJacParens=jacParens+leftJacParens+addParens;


    push(visitor,leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);


    PackageLocation="optim.problemdef.gradients.prod";
    visitor.PkgDepends(end+1)=PackageLocation;

end
