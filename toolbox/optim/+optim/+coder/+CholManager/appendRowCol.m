function obj=appendRowCol(obj,col)

%#codegen

    coder.allowpcode('plain');


    validateattributes(col,{'double'},{'vector'});

    INT_ONE=coder.internal.indexInt(1);

    obj.ndims=obj.ndims+1;


    for j=coder.internal.indexInt(1):obj.ndims-1
        obj.FMat(j,obj.ndims)=col(j);

        d=coder.internal.blas.xdot(j-1,obj.FMat,1+obj.ldm*(obj.ndims-1),INT_ONE,...
        obj.FMat,1+obj.ldm*(j-1),INT_ONE);

        obj.FMat(j,obj.ndims)=(obj.FMat(j,obj.ndims)-d)/obj.FMat(j,j);
    end


    d=coder.internal.blas.xdot(obj.ndims-1,obj.FMat,1+obj.ldm*(obj.ndims-1),INT_ONE,...
    obj.FMat,1+obj.ldm*(obj.ndims-1),INT_ONE);

    obj.FMat(obj.ndims,obj.ndims)=col(obj.ndims)-d;

    if(obj.FMat(obj.ndims,obj.ndims)<0)

        obj.info(:)=cast(5,'like',coder.internal.lapack.info_t);
        return;
    end

    obj.FMat(obj.ndims,obj.ndims)=sqrt(obj.FMat(obj.ndims,obj.ndims));
end