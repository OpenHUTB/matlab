









function[singularVectLeft,singularVal,singularVectRight]=computeBatchedSvd(inpMat)
%#codegen




    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    [nRows,nCols,nChan]=size(inpMat);

    if~isGPUCodegen()
        minDim=min(nCols,nRows);
        singularVectLeft=coder.nullcopy(zeros(nRows,nRows,nChan,'like',inpMat));
        singularVectRight=coder.nullcopy(zeros(nCols,nCols,nChan,'like',inpMat));
        singularVal=coder.nullcopy(zeros(minDim,nChan,'like',inpMat));

        for i=1:size(inpMat,3)
            [singularVectLeft(:,:,i),tmpMat,singularVectRight(:,:,i)]=svd(inpMat(:,:,i));
            singularVal(:,i)=diag(tmpMat(1:minDim,1:minDim));
        end
    else


        coder.cinclude('cusolverDn.h');
        if~coder.target('MEX')
            coder.updateBuildInfo('addLinkFlags','-lcusolver');
        end


        singularVectLeft=coder.nullcopy(zeros(nRows,nRows,nChan,'like',inpMat));
        singularVectRight=coder.nullcopy(zeros(nCols,nCols,nChan,'like',inpMat));
        singularVal=coder.nullcopy(zeros(min(nCols,nRows),nChan,'like',inpMat));


        if isa(inpMat,'single')
            if isreal(inpMat)
                fname='cusolverDnSgesvdjBatched';
                fnameBuffer='cusolverDnSgesvdjBatched_bufferSize';
            else
                fname='cusolverDnCgesvdjBatched';
                fnameBuffer='cusolverDnCgesvdjBatched_bufferSize';
            end
        else
            if isreal(inpMat)
                fname='cusolverDnDgesvdjBatched';
                fnameBuffer='cusolverDnDgesvdjBatched_bufferSize';
            else
                fname='cusolverDnZgesvdjBatched';
                fnameBuffer='cusolverDnZgesvdjBatched_bufferSize';
            end
        end


        cuSolverHandle=coder.opaque('cusolverDnHandle_t','NULL');
        coder.ceval('cusolverDnCreate',coder.ref(cuSolverHandle));


        svdjParams=coder.opaque('gesvdjInfo_t','NULL');
        coder.ceval('cusolverDnCreateGesvdjInfo',coder.ref(svdjParams));


        tolVal=eps(class(inpMat));
        coder.ceval('cusolverDnXgesvdjSetTolerance',svdjParams,tolVal);


        maxSweeps=20;
        coder.ceval('cusolverDnXgesvdjSetMaxSweeps',svdjParams,maxSweeps);


        workSpaceSize=int32(0);
        eigenMode=coder.opaque('cusolverEigMode_t','CUSOLVER_EIG_MODE_VECTOR');
        coder.ceval(fnameBuffer,cuSolverHandle,eigenMode,...
        nRows,nCols,coder.ref(inpMat,'gpu'),nRows,coder.ref(singularVal,'gpu'),...
        coder.ref(singularVectLeft,'gpu'),nRows,coder.ref(singularVectRight,'gpu'),nCols,...
        coder.ref(workSpaceSize),svdjParams,nChan);


        workSpaceMat=coder.nullcopy(zeros(1,workSpaceSize,'like',inpMat));
        infoArray=coder.nullcopy(zeros(1,nChan,'int32'));


        coder.ceval(fname,cuSolverHandle,eigenMode,...
        nRows,nCols,coder.ref(inpMat,'gpu'),nRows,coder.ref(singularVal,'gpu'),...
        coder.ref(singularVectLeft,'gpu'),nRows,coder.ref(singularVectRight,'gpu'),nCols,...
        coder.ref(workSpaceMat,'gpu'),workSpaceSize,coder.ref(infoArray,'gpu'),...
        svdjParams,nChan);


        coder.ceval('cusolverDnDestroy',cuSolverHandle);



        info=cast(infoArray,'like',coder.internal.lapack.info_t);
        if coder.internal.lapack.infocheck(info,fname,[],'negative')
            singularVectLeft(:)=coder.internal.nan;
            singularVectRight(:)=coder.internal.nan;
            singularVal(:)=coder.internal.nan;
        end
    end
end



function flag=isGPUCodegen()
    flag=coder.gpu.internal.isGpuEnabled;
end
