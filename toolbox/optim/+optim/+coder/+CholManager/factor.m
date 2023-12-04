function obj=factor(obj,A,ndims,ldA)

%#codegen

    coder.allowpcode('plain');

    validateattributes(A,{'double'},{'2d'});
    validateattributes(ndims,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldA,{coder.internal.indexIntClass},{'scalar'});

    INT_ONE=coder.internal.indexInt(1);

    obj.ndims(:)=ndims;

    if~isempty(A)

        for idx=1:ndims
            iA0=coder.internal.indexInt(1+ldA*(idx-1));
            iUU0=coder.internal.indexInt(1+obj.ldm*(idx-1));
            obj.FMat=coder.internal.blas.xcopy(ndims,A,iA0,INT_ONE,obj.FMat,iUU0,INT_ONE);
        end
    end

    [obj.FMat,obj.info(:)]=coder.internal.lapack.xpotrf('U',ndims,obj.FMat,INT_ONE,obj.ldm);

end

