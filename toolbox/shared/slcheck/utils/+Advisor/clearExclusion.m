function clearExclusion(modelName)

















    try
        manager=slcheck.getAdvisorFilterManager(modelName);
        manager.clear;
        slcheck.refreshExclusionUI(modelName);
    catch ex
        warning([DAStudio.message('slcheck:filtercatalog:ExclusionAPI_clear'),ex.message]);
    end

end

