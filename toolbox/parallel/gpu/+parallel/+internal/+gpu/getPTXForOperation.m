function[ptxText,ptxCallInfo]=...
    getPTXForOperation(fcnInfoStruct,expansionkey,varargin)











    if isempty(expansionkey)

        ruleset='vector';
    else

        ruleset='singleton';
    end


    if strcmp(fcnInfoStruct.type,'anonymous')



        treeFcn=@(IS)parallel.internal.tree.getTreeForFunction(fcnInfoStruct.function,fcnInfoStruct.type,IS);
        printlinenumber=false;
    else
        treeFcn=@(IS)parallel.internal.tree.getTreeForFile(fcnInfoStruct.file,fcnInfoStruct.type,IS);
        printlinenumber=true;
    end

    try



        internalState=parallel.internal.gpu.InternalState(fcnInfoStruct.file,ruleset,printlinenumber);
        tree=treeFcn(internalState);
        [ptxText,ptxCallInfo]=...
        parallel.internal.gpu.ptxFactory(expansionkey,internalState,tree,fcnInfoStruct,varargin{:});
    catch err
        if~isempty(err.identifier)
            throw(err);
        else




            newerr=MException(message('parallel:gpu:kernel:CompilationErrorUnknown'));
            newerr=addCause(newerr,err);
            throw(newerr);
        end
    end

end
