function sizes=setSizes(xCurrent,cEq,cIneq,Aeq,Ain,xIndices,separateBounds)













    sizes.nVar=numel(xCurrent);
    sizes.mNonlinEq=numel(cEq);
    sizes.mNonlinIneq=numel(cIneq);
    sizes.mLinEq=size(Aeq,1);
    sizes.mLinIneq=size(Ain,1);
    sizes.nFixedVar=nnz(xIndices.fixed);
    sizes.nFiniteLb=nnz(xIndices.finiteLb);
    sizes.nFiniteUb=nnz(xIndices.finiteUb);


    sizes.mEq=sizes.mLinEq+sizes.nFixedVar+sizes.mNonlinEq;

    sizes.fixed_start=sizes.mLinEq+1;
    sizes.nonlinEq_start=sizes.mLinEq+sizes.nFixedVar+1;
    sizes.nonlinEq_end=sizes.mLinEq+sizes.nFixedVar+sizes.mNonlinEq;
    sizes.ineq_start=sizes.mEq+1;




    if separateBounds

        sizes.mIneq=sizes.mLinIneq+sizes.mNonlinIneq;

        sizes.nonlinIneq_start=sizes.ineq_start+sizes.mLinIneq;
        sizes.finiteLb_start=sizes.nonlinIneq_start+sizes.mNonlinIneq;
        sizes.finiteUb_start=sizes.finiteLb_start+sizes.nFiniteLb;
    else

        sizes.mIneq=sizes.mLinIneq+sizes.nFiniteLb+sizes.nFiniteUb+sizes.mNonlinIneq;
        sizes.nonlinIneq_start=sizes.ineq_start+sizes.mLinIneq+sizes.nFiniteLb+sizes.nFiniteUb;
        sizes.finiteLb_start=sizes.ineq_start+sizes.mLinIneq;
        sizes.finiteUb_start=sizes.finiteLb_start+sizes.nFiniteLb;
    end

    sizes.mAll=sizes.mEq+sizes.mIneq;
    sizes.nPrimal=sizes.nVar+sizes.mIneq;
    sizes.mBnd=sizes.nFiniteLb+sizes.nFiniteUb;

    sizes.xShape=size(xCurrent);
