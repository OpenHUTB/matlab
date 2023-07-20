


function getNewCovMetricsAndUpdateDB(crID,covObjects)
    metadata=stm.internal.getTestManagerCoverageResults(crID);
    result=sltest.testmanager.TestResult.getResultFromID(metadata.FK_TestResult);
    assert(class(result)=="sltest.testmanager.ResultSet");

    updatedCov=stm.internal.Coverage.getMetrics(...
    covObjects,metadata.HarnessType,metadata.AnalyzedModel);


    idx=strlength({updatedCov.filename})==0;
    if any(idx)
        updatedCov=updatedCov(idx);
        error(message('Simulink:Commands:OpenSystemUnknownSystem',updatedCov(1).analyzedModel));
    end

    stm.internal.updateCoverageResults(updatedCov,crID,'UpdateDatabase');
end
