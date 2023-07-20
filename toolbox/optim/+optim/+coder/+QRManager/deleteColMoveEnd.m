function obj=deleteColMoveEnd(obj,idx)

















%#codegen

    coder.allowpcode('plain');

    validateattributes(idx,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);


    if(obj.usedPivoting)
        i=coder.internal.indexInt(1);
        while(i<=obj.ncols&&obj.jpvt(i)~=idx)
            i=i+1;
        end

        idx=i;
    end


    if(idx>=obj.ncols)
        obj.ncols=obj.ncols-1;
        return;
    end


    obj.jpvt(idx)=obj.jpvt(obj.ncols);




    for k=1:obj.minRowCol
        qrMoveTo=k+obj.ldq*(idx-INT_ONE);
        qrMoveFrom=k+obj.ldq*(obj.ncols-INT_ONE);
        obj.QR(qrMoveTo)=obj.QR(qrMoveFrom);
    end




    obj.ncols=obj.ncols-1;
    obj.minRowCol=min(obj.mrows,obj.ncols);




    if(idx>=obj.mrows)
        return;
    end

    endIdx=coder.internal.indexInt(min(obj.mrows-1,obj.ncols));

    k=endIdx;
    idxRotGCol=obj.ldq*(idx-INT_ONE);
    while(k>=idx)


        [obj.QR(k+idxRotGCol),obj.QR(k+1+idxRotGCol),c,s]=...
        coder.internal.blas.xrotg(obj.QR(k+idxRotGCol),obj.QR(k+1+idxRotGCol));




        qrSubDiag=k+1+obj.ldq*(k-INT_ONE);
        obj.QR(qrSubDiag)=0.0;





        QRk0=k+obj.ldq*idx;
        QRk10=1+QRk0;
        obj.QR=coder.internal.refblas.xrot(obj.ncols-idx,obj.QR,QRk0,obj.ldq,[],QRk10,obj.ldq,c,s);



        Qk0=1+obj.ldq*(k-1);
        Qk10=obj.ldq+Qk0;
        obj.Q=coder.internal.refblas.xrot(obj.mrows,obj.Q,Qk0,INT_ONE,[],Qk10,INT_ONE,c,s);

        k=k-1;
    end




    for k=coder.internal.indexInt(idx+1):endIdx

        idxRotGCol=obj.ldq*(k-INT_ONE);
        [obj.QR(k+idxRotGCol),obj.QR(k+1+idxRotGCol),c,s]=...
        coder.internal.blas.xrotg(obj.QR(k+idxRotGCol),obj.QR(k+1+idxRotGCol));




        QRk0=k*(obj.ldq+1);
        QRk10=1+QRk0;
        obj.QR=coder.internal.refblas.xrot(obj.ncols-k,obj.QR,QRk0,obj.ldq,[],QRk10,obj.ldq,c,s);



        Qk0=1+obj.ldq*(k-1);
        Qk10=obj.ldq+Qk0;
        obj.Q=coder.internal.refblas.xrot(obj.mrows,obj.Q,Qk0,INT_ONE,[],Qk10,INT_ONE,c,s);
    end

end