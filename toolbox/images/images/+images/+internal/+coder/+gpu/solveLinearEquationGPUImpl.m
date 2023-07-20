function sol=solveLinearEquationGPUImpl(rowIdx,colIdx,inpVal,rightSide)



























%#codegen


    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');





    if isGPUCodegen()


        coder.cinclude('cusolverSp.h');
        coder.cinclude('cusparse.h');


        if~coder.target('MEX')
            coder.updateBuildInfo('addLinkFlags','-lcusolver -lcusparse');
        end


        sol=coder.nullcopy(zeros(size(rightSide)));


        if isa(inpVal,'single')
            fname='cusolverSpScsrlsvchol';
        else
            fname='cusolverSpDcsrlsvchol';
        end


        cuSolverHandle=coder.opaque('cusolverSpHandle_t','NULL');
        coder.ceval('cusolverSpCreate',coder.ref(cuSolverHandle));


        cuSparseHandle=coder.opaque('cusparseHandle_t','NULL');
        coder.ceval('cusparseCreate',coder.ref(cuSparseHandle));


        cuSolverMatDescr=coder.opaque('cusparseMatDescr_t','NULL');
        coder.ceval('cusparseCreateMatDescr',coder.ref(cuSolverMatDescr));


        matFlag=coder.opaque('cusparseMatrixType_t','CUSPARSE_MATRIX_TYPE_GENERAL');
        baseFlag=coder.opaque('cusparseIndexBase_t','CUSPARSE_INDEX_BASE_ONE');


        coder.ceval('cusparseSetMatType',cuSolverMatDescr,matFlag);
        coder.ceval('cusparseSetMatIndexBase',cuSolverMatDescr,baseFlag);


        toleranceVal=eps(class(inpVal));
        rightSideSize=numel(rightSide);
        nnzSize=numel(colIdx);
        reorder=int32(3);
        singularity=int32(0);


        csrI=coder.nullcopy(zeros(rightSideSize+1,1,'int32'));



        coocsrfname='cusparseXcoo2csr';


        coder.ceval(coocsrfname,cuSparseHandle,coder.rref(rowIdx,'gpu'),nnzSize,...
        rightSideSize,coder.ref(csrI,'gpu'),baseFlag);



        coder.ceval(fname,cuSolverHandle,rightSideSize,nnzSize,cuSolverMatDescr,...
        coder.rref(inpVal,'gpu'),coder.rref(csrI,'gpu'),coder.rref(colIdx,'gpu'),...
        coder.rref(rightSide,'gpu'),toleranceVal,reorder,coder.ref(sol,'gpu'),...
        coder.ref(singularity));


        coder.ceval('cusolverSpDestroy',cuSolverHandle);


        coder.ceval('cusparseDestroy',cuSparseHandle);

    else

        D=sparse(rowIdx,colIdx,inpVal);

        sol=D\rightSide;

    end
end



function flag=isGPUCodegen()
    flag=coder.gpu.internal.isGpuEnabled;
end
