function writeCompiledFcn(funstruct,inMemory,useParallel,filepath)












    filewriterOnWorkers=@(~,~,~)[];
    if inMemory
        filewriter=@optim.internal.problemdef.writeCompiledFun2VirtualFile;
        if useParallel
            pool=gcp;
            if~isempty(pool)&&~isa(pool,'parallel.ThreadPool')


                filewriterOnWorkers=@(fname,fbody,filepath)parallel.pool.Constant(@()optim.internal.problemdef.writeCompiledFun2VirtualFile(fname,fbody,filepath));
            end
        end
    else
        filewriter=@optim.internal.problemdef.writeCompiledFun2StandardFile;
    end


    fnames=fieldnames(funstruct);
    for i=1:length(fnames)
        fcnName=fnames{i};
        filewriter(fcnName,funstruct.(fcnName),filepath);
        filewriterOnWorkers(fcnName,funstruct.(fcnName),filepath);
    end
