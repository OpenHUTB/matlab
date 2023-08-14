function visitOperatorSum(visitor,op,Node)





    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushJacAllZeros(visitor,numel(Node.ExprLeft));
        return;
    end


    addParens=1;
    [jacVarName,jacParens,jacIsArgOrVar]=getParentJacArgumentName(visitor,addParens);




    dimi=op.Dimension;
    LDims=op.LeftSize;


    if matlab.internal.datatypes.isScalarText(dimi)
        leftJac="repmat("+jacVarName+","+prod(LDims)+",1)";
        leftJacParens=jacParens+1;
        leftJacIsArgOrVar=false;
    elseif dimi>numel(LDims)


        leftJac=jacVarName;
        leftJacParens=jacParens;
        leftJacIsArgOrVar=jacIsArgOrVar;
    else

        [SMat,visitor.ExprBody]=optim.internal.problemdef.visitor.CompileForwardAD.createSumSMatString(visitor.ExprBody,LDims,dimi);

        if jacVarName=="1"
            leftJac=SMat;
            leftJacIsArgOrVar=true;
        else
            leftJac="("+SMat+"*"+jacVarName+")";
            leftJacIsArgOrVar=false;
        end
        leftJacParens=jacParens+1;
    end
    leftJacIsAllZero=false;


    push(visitor,leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);

end
