function term(modelcovId)




    try

        cv('set',modelcovId,'.refModelcovIds',[]);
        SlCov.CoverageAPI.safe_set_cv_object(modelcovId,'.topModelCov',[]);

    catch MEx
        rethrow(MEx);
    end


