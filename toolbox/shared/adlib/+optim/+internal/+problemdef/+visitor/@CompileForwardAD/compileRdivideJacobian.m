function compileRdivideJacobian(visitor,LeftExpr,leftJacVarName,leftJacParens,jacLeftStr,addLeftParens,...
    RightExpr,rightJacVarName,rightJacParens,jacRightStr,addRightParens)





    addJacParens=addLeftParens+addRightParens;


    scalarLeft=isscalar(LeftExpr);
    scalarRight=isscalar(RightExpr);
    if scalarLeft&&~scalarRight
        leftJacVarName="repmat("+leftJacVarName+", 1, "+numel(RightExpr)+")";
        addJacParens=addJacParens+1;
    elseif scalarRight&&~scalarLeft
        rightJacVarName="repmat("+rightJacVarName+", 1, "+numel(LeftExpr)+")";
        addJacParens=addJacParens+1;
    end


    leftJac=leftJacVarName+"*"+jacLeftStr;
    rightJac=rightJacVarName+"*"+jacRightStr;


    jacStr="("+leftJac+" + "+rightJac+")";
    jacParens=leftJacParens+rightJacParens+...
    addJacParens+1;
    jacIsArgOrVar=false;
    jacIsAllZero=false;


    pushJac(visitor,jacStr,jacParens,jacIsArgOrVar,jacIsAllZero);


    PackageLocation="optim.problemdef.gradients.divide";
    visitor.PkgDepends(end+1)=PackageLocation;

end
