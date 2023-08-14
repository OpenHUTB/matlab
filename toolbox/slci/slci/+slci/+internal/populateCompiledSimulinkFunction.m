






function out=populateCompiledSimulinkFunction(mdl)
    mdlName=mdl.getName;
    out=containers.Map('KeyType','double','ValueType','any');
    mgr=slci.internal.ModelStateMgr(mdlName);
    assert(mgr.isCompiled,['Model should be at compiled state when populate '...
    ,'Simulink Function info']);
    try
        funcInfo=get_param(mdlName,'CompiledSimulinkFunctions');
    catch


        return;
    end
    funcs=funcInfo.compFunctions;
    for i=1:funcs.Size
        callers=funcs(i).callerBlocks;
        slfcnInfo=slci.SimulinkFunctionInfo(funcs(i));
        mdl.registerCompiledSLFcnInfo(slfcnInfo);
        for j=1:callers.Size
            callerPath=callers(j);
            callerHandle=get_param(callerPath{1},'Handle');
            if~isKey(out,callerHandle)
                out(callerHandle)={slfcnInfo.getFcnBlkHdl};
            else
                fcns=out(callerHandle);
                fcns{end+1}=slfcnInfo.getFcnBlkHdl;%#ok
                out(callerHandle)=fcns;
            end
        end
    end
end