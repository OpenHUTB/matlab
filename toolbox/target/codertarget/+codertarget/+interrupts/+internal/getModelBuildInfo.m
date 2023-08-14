function buildInfo=getModelBuildInfo(ModelName)




    modelCodegenMgr=coder.internal.ModelCodegenMgr.getInstance(ModelName);
    if~isempty(modelCodegenMgr)
        buildInfo=modelCodegenMgr.BuildInfo;
    else
        buildInfo=[];
    end

end
