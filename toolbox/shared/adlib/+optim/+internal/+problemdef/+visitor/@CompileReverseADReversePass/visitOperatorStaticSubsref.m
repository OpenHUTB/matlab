function visitOperatorStaticSubsref(visitor,~,Node)






    addParens=Inf;
    jacStr=getArgumentName(visitor,addParens);
    visitor.Head=visitor.Head-1;





    linIdxBody=getForwardMemory(visitor);
    getForwardMemory(visitor);
    linIdxStr=getForwardMemory(visitor);


    leftJacStr="arg"+visitor.getNumArgs();
    leftJacNumParens=0;
    leftJacIsArgOrVar=true;
    leftJacIsAllZero=false;

    if~strcmp(linIdxStr,':')

        leftJacStrInit="arg"+visitor.getNumArgs();
        leftJacInit=leftJacStrInit+...
        " = zeros("+numel(Node.ExprLeft)+","+visitor.NumExpr+");"+newline;
        addToPreLoopBody(visitor,leftJacInit);


        leftFcnBody=leftJacStr+" = SubsrefAdjoint("+leftJacStrInit+", "+...
        jacStr+", "+linIdxStr+");"+newline;

        PackageLocation="optim.problemdef.gradients.indexing";
        visitor.PkgDepends(end+1)=PackageLocation;
    else


        leftFcnBody="";
        leftJacStr=jacStr;
    end


    visitor.ExprBody=visitor.ExprBody+linIdxBody+leftFcnBody;

    push(visitor,leftJacStr,leftJacNumParens,leftJacIsArgOrVar,leftJacIsAllZero);

end
