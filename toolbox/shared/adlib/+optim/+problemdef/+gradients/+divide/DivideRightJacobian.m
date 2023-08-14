function rightJac=DivideRightJacobian(left,right)







































    gradRight=-left(:)./(right(:).^2);
    nExpr=numel(gradRight);
    if nExpr==1
        rightJac=gradRight;
    else
        rightJac=speye(nExpr,nExpr).*gradRight;
    end
