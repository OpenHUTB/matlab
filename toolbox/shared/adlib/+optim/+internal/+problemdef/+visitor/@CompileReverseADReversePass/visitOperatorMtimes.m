function visitOperatorMtimes(visitor,~,Node)





    [rightIsAllZero,rightVarName]=getChildMemory(visitor);
    [leftIsAllZero,leftVarName]=getChildMemory(visitor);


    jacIsAllZero=isParentJacAllZero(visitor);
    if jacIsAllZero

        visitor.Head=visitor.Head-1;
        pushAllZeroChild(visitor,1,Node.ExprLeft);
        pushAllZeroChild(visitor,2,Node.ExprRight);
        return;
    end






    addParens=Inf;
    [jacVarName,jacParens]=getParentJacArgumentName(visitor,addParens);


    ExprLeft=Node.ExprLeft;
    ExprRight=Node.ExprRight;
    appendPackageLocation=false;

    if rightIsAllZero

        pushAllZeroChild(visitor,1,ExprLeft);
    else

        leftSize=size(ExprLeft);
        jacFunInputStr="(["+leftSize(1)+" "+leftSize(2)+"], "+rightVarName+", "+jacVarName+")";
        FileNameLeftAdjoint="MtimesLeftAdjoint";
        leftJac=FileNameLeftAdjoint+jacFunInputStr;
        leftJacParens=jacParens+1;
        leftJacIsArgOrVar=false;
        leftJacIsAllZero=false;
        pushChild(visitor,1,leftJac,leftJacParens,leftJacIsArgOrVar,leftJacIsAllZero);
        appendPackageLocation=true;
    end

    if leftIsAllZero

        pushAllZeroChild(visitor,2,ExprRight);
    else

        rightSize=size(ExprRight);
        jacFunInputStr="("+leftVarName+", ["+rightSize(1)+" "+rightSize(2)+"], "+jacVarName+")";
        FileNameRightAdjoint="MtimesRightAdjoint";
        rightJac=FileNameRightAdjoint+jacFunInputStr;
        rightJacParens=jacParens+1;
        rightJacIsArgOrVar=false;
        rightJacIsAllZero=false;
        pushChild(visitor,2,rightJac,rightJacParens,rightJacIsArgOrVar,rightJacIsAllZero);
        appendPackageLocation=true;
    end


    if appendPackageLocation
        PackageLocation="optim.problemdef.gradients.mtimes";
        visitor.PkgDepends(end+1)=PackageLocation;
    end

end
