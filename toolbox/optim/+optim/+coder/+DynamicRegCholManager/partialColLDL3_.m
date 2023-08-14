function obj=partialColLDL3_(obj,LD_offset,NColsRemain,REG_PRIMAL,BLOCK_SIZE)















%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(LD_offset,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(NColsRemain,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(REG_PRIMAL,{'double'},{'scalar'});
    validateattributes(BLOCK_SIZE,{coder.internal.indexIntClass},{'scalar'});


    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    LDimSizeP1=coder.internal.indexInt(obj.ldm+1);

    for k=INT_ZERO:BLOCK_SIZE-1

        subRows=NColsRemain-k;
        subCols=k;

        LD_diagOffset=coder.internal.indexInt(LD_offset+LDimSizeP1*k);
        W_diagOffset=coder.internal.indexInt(1+LDimSizeP1*k);

        for idx=INT_ZERO:(subRows-INT_ONE)
            obj.workspace_(W_diagOffset+idx)=obj.FMat(LD_diagOffset+idx);
        end

        offsetColK=coder.internal.indexInt(1+obj.ldm*k);



        for idx=INT_ZERO:(NColsRemain-INT_ONE)
            obj.workspace2_(INT_ONE+idx)=obj.workspace_(offsetColK+idx);
        end

        obj.workspace2_=coder.internal.blas.xgemv('N',NColsRemain,subCols,-1.0,...
        obj.workspace_,INT_ONE,obj.ldm,...
        obj.FMat,LD_offset+k,obj.ldm,...
        1.0,obj.workspace2_,INT_ONE,INT_ONE);


        for idx=INT_ZERO:(NColsRemain-INT_ONE)
            obj.workspace_(offsetColK+idx)=obj.workspace2_(INT_ONE+idx);
        end

        for idx=INT_ZERO:(subRows-INT_ONE)
            obj.FMat(LD_diagOffset+idx)=obj.workspace_(W_diagOffset+idx);
        end

        if(abs(obj.FMat(LD_diagOffset))<=obj.regTol_)


            obj.FMat(LD_diagOffset)=obj.FMat(LD_diagOffset)+REG_PRIMAL;
        end


        numStrictLowerRows=coder.internal.indexInt(subRows-1);
        for idx=INT_ONE:numStrictLowerRows
            obj.FMat(LD_diagOffset+idx)=obj.FMat(LD_diagOffset+idx)/obj.FMat(LD_diagOffset);
        end







    end

    for j=BLOCK_SIZE:BLOCK_SIZE:NColsRemain-1

        subBlockSize=min(BLOCK_SIZE,NColsRemain-j);

        for k=j:(j+subBlockSize-1)

            subRows=j+subBlockSize-k;
            LD_diagOffset=coder.internal.indexInt(LD_offset+LDimSizeP1*k);


            for idx=INT_ZERO:(BLOCK_SIZE-INT_ONE)
                obj.workspace2_(INT_ONE+idx)=obj.FMat(LD_offset+k+idx*obj.ldm);
            end

            obj.FMat=coder.internal.blas.xgemv('N',subRows,BLOCK_SIZE,-1.0,...
            obj.workspace_,k+1,obj.ldm,...
            obj.workspace2_,INT_ONE,INT_ONE,...
            1.0,obj.FMat,LD_diagOffset,INT_ONE);
        end

        if(j+subBlockSize<NColsRemain)

            subRows=NColsRemain-j-subBlockSize;

            Woffset=coder.internal.indexInt(j+subBlockSize+1);
            LDFinalOffset=coder.internal.indexInt(LD_offset+subBlockSize+LDimSizeP1*j);



            for idx=1:BLOCK_SIZE
                FMat_offset=coder.internal.indexInt(LD_offset+j+(idx-1)*obj.ldm);
                workspace2_offset=coder.internal.indexInt(1+(idx-1)*obj.ldm);

                for idx2=INT_ZERO:(subBlockSize-INT_ONE)
                    obj.workspace2_(workspace2_offset+idx2)=obj.FMat(FMat_offset+idx2);
                end

            end


            obj.FMat=coder.internal.blas.xgemm('N','T',subRows,subBlockSize,BLOCK_SIZE,...
            -1.0,obj.workspace_,Woffset,obj.ldm,...
            obj.workspace2_,INT_ONE,obj.ldm,...
            1.0,obj.FMat,LDFinalOffset,obj.ldm);
        end

    end

end

