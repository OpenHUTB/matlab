function obj=fullColLDL2_(obj,LD_offset,NColsRemain,REG_PRIMAL)














%#codegen

    coder.allowpcode('plain');

    validateattributes(obj,{'struct'},{'scalar'});
    validateattributes(LD_offset,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(NColsRemain,{coder.internal.indexIntClass},{'scalar'});
    validateattributes(REG_PRIMAL,{'double'},{'scalar'});

    INT_ZERO=coder.internal.indexInt(0);
    INT_ONE=coder.internal.indexInt(1);

    LDimSizeP1=coder.internal.indexInt(obj.ldm+1);



    for k=INT_ONE:NColsRemain
        LD_diagOffset=coder.internal.indexInt(LD_offset+LDimSizeP1*(k-1));

        if(abs(obj.FMat(LD_diagOffset))<=obj.regTol_)


            obj.FMat(LD_diagOffset)=obj.FMat(LD_diagOffset)+REG_PRIMAL;
        end


        neg_D=-1.0/obj.FMat(LD_diagOffset);
        subMatrixDim=coder.internal.indexInt(NColsRemain-k);


        offset1=LD_diagOffset+1;
        offset2=LD_diagOffset+LDimSizeP1;







        obj.workspace_=coder.internal.blas.xcopy(subMatrixDim,obj.FMat,offset1,INT_ONE,obj.workspace_,INT_ONE,INT_ONE);
        obj.FMat=coder.internal.blas.xger(subMatrixDim,subMatrixDim,neg_D,...
        obj.workspace_,INT_ONE,INT_ONE,...
        obj.workspace_,INT_ONE,INT_ONE,...
        obj.FMat,offset2,obj.ldm);









        L_diagScale=1.0/obj.FMat(LD_diagOffset);
        obj.FMat=coder.internal.blas.xscal(subMatrixDim,L_diagScale,obj.FMat,offset1,INT_ONE);
    end


    lastDiag=coder.internal.indexInt(LD_offset+LDimSizeP1*(NColsRemain-1));
    if(abs(obj.FMat(lastDiag))<=obj.regTol_)


        obj.FMat(lastDiag)=obj.FMat(lastDiag)+REG_PRIMAL;
    end

end

