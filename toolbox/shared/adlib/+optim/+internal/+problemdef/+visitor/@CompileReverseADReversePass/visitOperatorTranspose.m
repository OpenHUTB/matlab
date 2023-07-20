function visitOperatorTranspose(visitor,op,Node)





    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushJacAllZeros(visitor,numel(Node.ExprLeft));
        return;
    end




    addParens=Inf;
    [jacVarName,jacParens]=getParentJacArgumentName(visitor,addParens);


    outSize=getOutputSize(op,size(Node.ExprLeft),[]);
    leftJac="TransposeAdjoint("+jacVarName+",["+outSize(1)+" "+outSize(2)+"])";
    leftJacParens=jacParens+2;
    leftJacIsArgOrVar=false;
    leftJacIsAllZero=false;


    push(visitor,leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);

    PackageLocation="optim.problemdef.gradients.indexing";
    visitor.PkgDepends(end+1)=PackageLocation;

end
