function res=isModelRefEnabledFromTop(modelName)




    res=false;
    try
        info=cvi.ModelInfoCache.getTopModelInfo();
        if~isempty(info.topModel)
            res=cv.ModelRefData.assessModelRefEnabled(modelName,...
            info.modelRefEnable,...
            info.modelRefExcludeList);
        end
    catch
        res=false;
    end
end