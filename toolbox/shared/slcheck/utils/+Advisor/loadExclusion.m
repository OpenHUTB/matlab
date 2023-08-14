function loadExclusion(modelName,filePath)

















    try
        service=slcheck.AdvisorFilterService.getInstance;
        service.remove(modelName);
        absoluteFilePath=which(filePath);
        if~isempty(absoluteFilePath)
            filePath=absoluteFilePath;
        end
        instance=slcheck.AdvisorFilterService.getInstance;
        instance.getFilterManagerFromFile(modelName,filePath);
        slcheck.refreshExclusionUI(modelName);
    catch ex
        warning([DAStudio.message('slcheck:filtercatalog:ExclusionAPI_load'),ex.message]);
    end

end

