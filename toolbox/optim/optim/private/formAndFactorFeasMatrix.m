function[AugMatrix,AugFactor]=formAndFactorFeasMatrix(AugMatrix,AugFactor,JacTrans,...
    slacksRelaxEqPlus,slacksRelaxEqMinus,slacksIneq,slacksRelaxIneq,sizes,options)












    nVar=sizes.nVar;mEq=sizes.mEq;mIneq=sizes.mIneq;
    mEqId=speye(mEq);mIneqId=speye(mIneq);

    AugMatrix=[speye(nVar,nVar),sparse(JacTrans(1:nVar,1:mEq+mIneq)),sparse(nVar,2*mEq+mIneq);...
    sparse(mEq,nVar),-2*mEqId,sparse(mEq,mIneq),mEqId,-mEqId,sparse(mEq,mIneq);...
    sparse(mIneq,nVar+mEq),-spdiags(1+slacksIneq(:).^2,0,mIneq,mIneq),sparse(mIneq,2*mEq),-mIneqId;...
    sparse(mEq,nVar+mEq+mIneq),-spdiags(1+slacksRelaxEqPlus(:).^2,0,mEq,mEq),sparse(mEq,mEq+mIneq);...
    sparse(mEq,nVar+2*mEq+mIneq),-spdiags(1+slacksRelaxEqMinus(:).^2,0,mEq,mEq),sparse(mEq,mIneq);...
    sparse(mIneq,nVar+3*mEq+mIneq),-spdiags(1+slacksRelaxIneq(:).^2,0,mIneq,mIneq)];

    if strcmpi(options.LinearSystemSolver,'ldl-factorization')
        [AugFactor.U,AugFactor.D,AugFactor.p,AugFactor.S,~,augRank]...
        =ldl(AugMatrix,options.PivotThreshold,'upper','vector');

        AugFactor.FeasibilityStep=true;
    else
        error(message('optim:formAndFactorAugMatrix:BadLinearSystemSolver'));
    end




    AugFactor.nVar=sizes.nVar;
    AugFactor.mEq=sizes.mEq;
    AugFactor.mIneq=sizes.mIneq;

end
