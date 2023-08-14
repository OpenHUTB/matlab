function buildOptions=getIDEBuildOptions(h,ModelName,AdaptorName,ToolName)




    buildOptionsH=h.mAdaptorRegistry.getIDEBuildOptions(AdaptorName);
    if~isempty(buildOptionsH)
        buildOptions=buildOptionsH(ModelName,ToolName);
    else
        buildOptions=[];
    end
end
