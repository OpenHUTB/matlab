function coverageReportCallback(callbackInfo,varargin)




    modelName=callbackInfo.model.Name;
    obj=SlCov.CoverageAPI.getActiveData(modelName);
    if isempty(obj)
        return;
    end

    if isa(obj,'cvi.ResultsExplorer.ResultsExplorer')


        obj.reportCurrentData();
    else

        cvhtml([modelName,'_cov.html'],obj);
    end