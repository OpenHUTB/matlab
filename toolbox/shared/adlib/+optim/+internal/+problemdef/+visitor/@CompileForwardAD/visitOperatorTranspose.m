function visitOperatorTranspose(visitor,op,Node)





    visitOperatorTranspose@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);




    leftJacIsAllZero=isChildJacAllZero(visitor,1);
    if leftJacIsAllZero

        pushJacAllZeros(visitor,numel(Node));
        return;
    end


    addParens=Inf;
    [leftJacVarName,leftJacParens]=getChildJacArgumentName(...
    visitor,1,addParens);

    outSize=getOutputSize(op,size(Node.ExprLeft),[]);
    jacStr="TransposeTangent("+leftJacVarName+",["+outSize(1)+" "+outSize(2)+"])";
    jacNumParens=leftJacParens+2;
    jacIsArgOrVar=false;
    jacIsAllZero=false;


    pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);

    PackageLocation="optim.problemdef.gradients.indexing";
    visitor.PkgDepends(end+1)=PackageLocation;

end
