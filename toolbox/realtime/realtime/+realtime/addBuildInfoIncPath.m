function ret=addBuildInfoIncPath(fname,modelName)




    ret=0;

    if(isequal(get_param(modelName,'VmSimulationCompile'),'on'))
        return;
    end

    if~isempty(fname)
        if~iscell(fname)
            filename{1}=fname;
        else
            filename=fname;
        end

        modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(modelName);

        buildInfo=modelCodegenMgr.BuildInfo;

        buildInfo.addIncludePaths(filename,'include');
    end
