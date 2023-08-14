function modelCleanup(modelH)






    try

        if~strcmpi(get_param(modelH,'RecordCoverageOverride'),'LeaveAlone')

            cvi.TopModelCov.restoreCoverageEnable(modelH);
            cvi.TopModelCov.modelCovClear(modelH);
        else



            SlCov.CoverageAPI.resetOverrideOnCachedModels();
        end

        SlCov.CoverageAPI.resetModelInfoCache();
        SlCov.CoverageAPI.sfAutoscaleCache(modelH,'reset');

    catch SlCovExc
        rethrow(SlCovExc);
    end

