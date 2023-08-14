function updateBuildInfo(modelName,cmd,varargin)





    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(modelName);
    if isempty(modelCodegenMgr)
        return;
    end

    buildInfo=modelCodegenMgr.BuildInfo;
    feval(cmd,buildInfo,varargin{:});
