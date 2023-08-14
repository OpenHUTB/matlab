function leftJac=DivideLeftJacobian(right)















































    gradLeft=1./right(:);
    nExpr=numel(gradLeft);
    if nExpr==1
        leftJac=gradLeft;
    else
        leftJac=speye(nExpr,nExpr).*gradLeft;
    end
