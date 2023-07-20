function fscale=formScaling(grad,Ain,Aeq,JacCineqTrans,JacCeqTrans,sizes)












    mEq=sizes.mEq;
    mAll=sizes.mAll;
    mLinEq=sizes.mLinEq;mLinIneq=sizes.mLinIneq;
    nonlinIneq_start=sizes.nonlinIneq_start;
    nonlinEq_start=sizes.nonlinEq_start;

    tol=2.0*eps;



    fscale.obj=norm(grad,inf);

    if fscale.obj<tol
        fscale.obj=1.0;

        fscale.objIsScaled=false;
    else
        fscale.obj=min(1.0,100.0/fscale.obj);
        fscale.obj=max(1e-8,fscale.obj);

        fscale.objIsScaled=true;
    end





    fscale.constr=ones(mAll,1);
    fscale.constr(1:mLinEq)=max(abs(Aeq),[],2);
    fscale.constr(nonlinEq_start:mEq)=max(abs(JacCeqTrans),[],1);
    fscale.constr(mEq+1:mEq+mLinIneq)=max(abs(Ain),[],2);
    fscale.constr(nonlinIneq_start:mAll)=max(abs(JacCineqTrans),[],1);


    smallGradient_idx=fscale.constr<tol;
    fscale.constr(smallGradient_idx)=1.0;
    fscale.constr=min(1.0,(100.0./fscale.constr));
    fscale.constr=max(1e-8,fscale.constr);

    fscale.cEq=fscale.constr(nonlinEq_start:mEq,1);
    fscale.cIneq=fscale.constr(nonlinIneq_start:mAll,1);

