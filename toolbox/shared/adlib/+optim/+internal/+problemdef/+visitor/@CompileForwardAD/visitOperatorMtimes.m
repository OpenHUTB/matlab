function visitOperatorMtimes(visitor,op,Node)






    leftVarName=declareChildArgumentName(visitor,1);
    leftIsAllZero=isChildAllZero(visitor,1);
    rightVarName=declareChildArgumentName(visitor,2);
    rightIsAllZero=isChildAllZero(visitor,2);


    visitOperatorMtimes@optim.internal.problemdef.visitor.CompileNonlinearFunction(visitor,op,Node);


    leftJacIsAllZero=isChildJacAllZero(visitor,1);
    if rightIsAllZero||leftJacIsAllZero

        leftJacIsAllZero=true;
        leftJacParens=0;
        leftAddJacParens=0;
    else

        addJacParens=1;
        leftAddJacParens=1;
        [leftJacVarName,leftJacParens,~,leftJacIsAllZero]=getChildJacArgumentName(...
        visitor,1,leftAddJacParens+addJacParens);
        leftJac="MtimesLeftTangent("+leftVarName+", "+rightVarName+", "+leftJacVarName+")";
    end

    rightJacIsAllZero=isChildJacAllZero(visitor,2);
    if leftIsAllZero||rightJacIsAllZero

        rightJacIsAllZero=true;
    else

        addJacParens=leftAddJacParens;
        rightAddJacParens=1;
        [rightJacVarName,rightJacParens,~,rightJacIsAllZero]=getChildJacArgumentName(...
        visitor,2,leftJacParens+leftAddJacParens+rightAddJacParens+addJacParens);


        rightJac="MtimesRightTangent("+leftVarName+", "+rightVarName+", "+rightJacVarName+")";
    end


    if leftJacIsAllZero
        if rightJacIsAllZero

            pushJacAllZeros(visitor,numel(Node));
            return;
        else

            jacStr=rightJac;
            jacNumParens=rightJacParens+rightAddJacParens;
            jacIsArgOrVar=false;
            jacIsAllZero=false;
        end
    elseif rightJacIsAllZero

        jacStr=leftJac;
        jacNumParens=leftJacParens+leftAddJacParens;
        jacIsArgOrVar=false;
        jacIsAllZero=false;
    else

        jacStr="("+leftJac+" + "+rightJac+")";
        jacNumParens=leftJacParens+leftAddJacParens+...
        rightJacParens+rightAddJacParens+addJacParens;
        jacIsArgOrVar=false;
        jacIsAllZero=false;
    end


    pushJac(visitor,jacStr,jacNumParens,jacIsArgOrVar,jacIsAllZero);


    PackageLocation="optim.problemdef.gradients.mtimes";
    visitor.PkgDepends(end+1)=PackageLocation;
end
