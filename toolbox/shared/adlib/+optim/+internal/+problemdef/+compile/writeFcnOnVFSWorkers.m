function probStruct=writeFcnOnVFSWorkers(probStruct,prob,...
    useParallel,fcnFieldName,fcnName,fcnBody,extraParams)












    if useParallel

        pool=gcp;
        if~isempty(pool)&&~isa(pool,'parallel.ThreadPool')


            fcnhandle=parallel.pool.Constant(@()optim.internal.problemdef.writeCompiledFun2VirtualFile(...
            fcnName,fcnBody,prob.GeneratedFileFolder));
            extraParams=parallel.pool.Constant(extraParams);
            probStruct.FcnHandleForWorkers.(fcnFieldName)=...
            @(x)fcnhandle.Value(x,extraParams.Value);
        end
    end