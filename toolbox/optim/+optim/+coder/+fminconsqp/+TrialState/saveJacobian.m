function obj=saveJacobian(obj,nVar,mIneq,JacCineqTrans,ineqCol0,mEq,JacCeqTrans,eqCol0,ldJ)













%#codegen

    coder.allowpcode('plain');


    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(nVar,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mIneq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(JacCineqTrans,{'double'},{'2d'});
    validateattributes(ineqCol0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(mEq,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(JacCeqTrans,{'double'},{'2d'});
    validateattributes(eqCol0,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldJ,{coder.internal.indexIntClass},{'scalar'});

    coder.internal.prefer_const(nVar,mIneq,ineqCol0,mEq,eqCol0,ldJ);

    INT_ONE=coder.internal.indexInt(1);


    iCol=1+ldJ*(ineqCol0-1);
    iCol_old=coder.internal.indexInt(1);
    for idx_col=1:(mIneq-ineqCol0+1)

        obj.JacCineqTrans_old=coder.internal.blas.xcopy(nVar,JacCineqTrans,iCol,INT_ONE,obj.JacCineqTrans_old,iCol_old,INT_ONE);

        iCol=iCol+ldJ;
        iCol_old=iCol_old+ldJ;
    end


    iCol=1+ldJ*(eqCol0-1);
    iCol_old=coder.internal.indexInt(1);
    for idx_col=1:(mEq-eqCol0+1)

        obj.JacCeqTrans_old=coder.internal.blas.xcopy(nVar,JacCeqTrans,iCol,INT_ONE,obj.JacCeqTrans_old,iCol_old,INT_ONE);

        iCol=iCol+ldJ;
        iCol_old=iCol_old+ldJ;
    end

end

