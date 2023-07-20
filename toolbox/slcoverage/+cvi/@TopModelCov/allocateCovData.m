function allocateCovData(~,modelH)



    try

        modelcovId=get_param(modelH,'CoverageId');
        testId=cv('get',modelcovId,'.activeTest');
        cvi.TopModelCov.updateModelinfo(testId,modelH);
        cvi.TopModelCov.setTestObjective(modelcovId,testId);
        cv('allocateModelCoverageData',modelcovId);
        cv('recordSigrangeAtStart');
    catch MEx
        rethrow(MEx);
    end
end
