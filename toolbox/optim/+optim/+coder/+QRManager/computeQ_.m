function obj=computeQ_(obj,nrows)


















%#codegen

    coder.allowpcode('plain');

    validateattributes(nrows,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);


    for idx=INT_ONE:obj.minRowCol

        iQR0=coder.internal.indexInt(1+obj.ldq*(idx-1)+idx);
        obj.Q=coder.internal.blas.xcopy(obj.mrows-idx,obj.QR,iQR0,INT_ONE,obj.Q,iQR0,INT_ONE);
    end

    iq0=INT_ONE;
    itau0=INT_ONE;
    obj.Q=coder.internal.lapack.xorgqr(obj.mrows,nrows,obj.minRowCol,...
    obj.Q,iq0,obj.ldq,obj.tau,itau0);
end