function obj=factorQR(obj,A,mrows,ncols,ldA)















%#codegen

    coder.allowpcode('plain');


    validateattributes(A,{'double'},{'2d'});
    validateattributes(mrows,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ncols,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldA,{coder.internal.indexIntClass},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);



    if~isempty(A)&&(mrows*ncols>INT_ZERO)

        for idx=1:ncols
            iA0=coder.internal.indexInt(1+ldA*(idx-1));
            iQR0=coder.internal.indexInt(1+obj.ldq*(idx-1));
            obj.QR=coder.internal.blas.xcopy(mrows,A,iA0,INT_ONE,obj.QR,iQR0,INT_ONE);
        end
    elseif(mrows*ncols==INT_ZERO)
        obj.mrows(:)=mrows;
        obj.ncols(:)=ncols;
        obj.minRowCol(:)=INT_ZERO;
        return;
    end

    obj.usedPivoting=false;
    obj.mrows=mrows;
    obj.ncols=ncols;

    for idx=1:obj.ncols
        obj.jpvt(idx)=idx;
    end
    obj.minRowCol=coder.internal.indexInt(min(mrows,ncols));





    [obj.QR,obj.tau]=coder.internal.lapack.xgeqrf(obj.QR,INT_ONE,mrows,ncols);
end
