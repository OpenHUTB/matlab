function highlightActiveData(modelName)




    obj=SlCov.CoverageAPI.getActiveData(modelName);
    if isempty(obj)
        return;
    end

    if isa(obj,'cvi.ResultsExplorer.ResultsExplorer')

        obj.highlightCurrentData();
    else

        cvmodelview(obj);
    end
