function obj=squareQ_appendCol(obj,vec,iv0)














%#codegen

    coder.allowpcode('plain');

    validateattributes(vec,{'double'},{'2d'});
    validateattributes(iv0,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);

    obj.minRowCol=min(obj.mrows,obj.ncols+1);




    iQR0=1+obj.ldq*obj.ncols;
    obj.QR=coder.internal.blas.xgemv('T',obj.mrows,obj.mrows,1.0,obj.Q,INT_ONE,obj.ldq,...
    vec,iv0,INT_ONE,0.0,obj.QR,iQR0,INT_ONE);

    obj.ncols=obj.ncols+1;

    obj.jpvt(obj.ncols)=obj.ncols;

    idx=coder.internal.indexInt(obj.mrows);
    while(idx>obj.ncols)

        idxRotGCol=obj.ldq*(obj.ncols-INT_ONE);
        [obj.QR(idx-1+idxRotGCol),obj.QR(idx+idxRotGCol),c,s]=...
        coder.internal.blas.xrotg(obj.QR(idx-1+idxRotGCol),obj.QR(idx+idxRotGCol));






        Qk0=1+obj.ldq*(idx-2);
        Qk10=obj.ldq+Qk0;
        obj.Q=coder.internal.refblas.xrot(obj.mrows,obj.Q,Qk0,INT_ONE,[],Qk10,INT_ONE,c,s);

        idx=idx-1;
    end

end