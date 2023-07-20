function obj=deleteRowColMoveEnd(obj,idx)



















%#codegen

    coder.allowpcode('plain');


    validateattributes(idx,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);



    if(idx>=obj.ndims)
        obj.ndims=obj.ndims-1;
        return;
    end




    for k=1:obj.ndims
        obj.FMat(k,idx)=obj.FMat(k,obj.ndims);
    end








    obj.ndims=obj.ndims-1;

    endIdx=coder.internal.indexInt(obj.ndims);

    k=endIdx;
    while(k>=idx)


        [obj.FMat(k,idx),obj.FMat(k+1,idx),c,s]=coder.internal.blas.xrotg(obj.FMat(k,idx),obj.FMat(k+1,idx));
        GRot=[c,s;-s,c];




        obj.FMat(k+1,k)=0;



        obj.FMat(k:k+1,idx+1:obj.ndims)=GRot*obj.FMat(k:k+1,idx+1:obj.ndims);

        k=k-1;
    end




    for k=coder.internal.indexInt(idx+1):endIdx
        [obj.FMat(k,k),obj.FMat(k+1,k),c,s]=coder.internal.blas.xrotg(obj.FMat(k,k),obj.FMat(k+1,k));
        GRot=[c,s;-s,c];



        obj.FMat(k:k+1,k+1:obj.ndims)=GRot*obj.FMat(k:k+1,k+1:obj.ndims);
    end

end