function obj=factor(obj,A,ndims,ldA)












%#codegen

    coder.allowpcode('plain');

    validateattributes(A,{'double'},{'2d'});
    validateattributes(ndims,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(ldA,{coder.internal.indexIntClass},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);
    REG_PRIMAL=coder.const(optim.coder.DynamicRegCholManager.Constants('RegPrimal'));
    SCALED_REG_PRIMAL=REG_PRIMAL*obj.scaleFactor*double(ndims);
    BLOCK_SIZE=coder.const(optim.coder.DynamicRegCholManager.Constants('BlockSizeL3BLAS'));
    MAX_BLOCK_SIZE_L2_BLAS=coder.const(optim.coder.DynamicRegCholManager.Constants('MaxBlockSizeL2BLAS'));

    LDimSizeP1=obj.ldm+INT_ONE;

    obj.ndims(:)=ndims;

    if~isempty(A)

        for idx=1:ndims
            iA0=coder.internal.indexInt(1+ldA*(idx-1));
            iLD0=coder.internal.indexInt(1+obj.ldm*(idx-1));
            obj.FMat=coder.internal.blas.xcopy(ndims,A,iA0,INT_ONE,obj.FMat,iLD0,INT_ONE);
        end
    end


    A_maxDiag_idx=coder.internal.blas.ixamax(ndims,obj.FMat,INT_ONE,LDimSizeP1);
    diagIdx=A_maxDiag_idx+obj.ldm*(A_maxDiag_idx-INT_ONE);
    obj.regTol_=max(abs(obj.FMat(diagIdx))*eps('double'),abs(SCALED_REG_PRIMAL));



    if(numel(obj.FMat)>MAX_BLOCK_SIZE_L2_BLAS*MAX_BLOCK_SIZE_L2_BLAS&&...
        ndims>MAX_BLOCK_SIZE_L2_BLAS)


        k=INT_ZERO;
        while(k<ndims)
            LD_diagOffset=INT_ONE+LDimSizeP1*k;
            order=ndims-k;

            if(k+BLOCK_SIZE<=ndims)


                obj=optim.coder.DynamicRegCholManager.partialColLDL3_(obj,LD_diagOffset,order,SCALED_REG_PRIMAL,BLOCK_SIZE);
                k=k+BLOCK_SIZE;
            else


                obj=optim.coder.DynamicRegCholManager.fullColLDL2_(obj,LD_diagOffset,order,SCALED_REG_PRIMAL);
                break;
            end
        end
    else

        obj=optim.coder.DynamicRegCholManager.fullColLDL2_(obj,INT_ONE,ndims,SCALED_REG_PRIMAL);
    end


    if(obj.ConvexCheck)
        for idx=1:ndims
            idxDiag=idx+obj.ldm*(idx-INT_ONE);
            if(obj.FMat(idxDiag)<=0.0)
                obj.info(:)=-idx;
                return;
            end
        end
        obj.ConvexCheck=false;
    end

end

