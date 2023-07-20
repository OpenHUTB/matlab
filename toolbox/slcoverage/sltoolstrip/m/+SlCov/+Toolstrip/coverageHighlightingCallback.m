function coverageHighlightingCallback(callbackInfo,varargin)




    modelName=callbackInfo.model.Name;

    if callbackInfo.EventData

        SlCov.CoverageAPI.highlightActiveData(modelName);
    else

        modelName=SlCov.CoverageAPI.resolveModelUnderTest(modelName);
        cvi.Informer.close(get_param(modelName,'CoverageId'));
    end
