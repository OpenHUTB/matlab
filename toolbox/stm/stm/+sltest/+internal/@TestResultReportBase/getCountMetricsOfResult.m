function ret=getCountMetricsOfResult(resultObj)



















    outcome=resultObj.Outcome;
    resultType=sltest.testmanager.ReportUtility.getTypeOfTestResult(resultObj);
    if(resultType==sltest.testmanager.TestResultTypes.ResultSet||...
        resultType==sltest.testmanager.TestResultTypes.TestFileResult||...
        resultType==sltest.testmanager.TestResultTypes.TestSuiteResult)

        ret.numOfResults=resultObj.NumTotal;
        ret.numOfPassed=resultObj.NumPassed;
        ret.numOfFailed=resultObj.NumFailed;
        ret.numOfDisabled=resultObj.NumDisabled;
        ret.numOfIncomplete=resultObj.NumIncomplete;
    elseif(resultType==sltest.testmanager.TestResultTypes.TestCaseResult&&resultObj.NumTotalIterations>0)
        ret.numOfResults=resultObj.NumTotalIterations;
        ret.numOfPassed=resultObj.NumPassedIterations;
        ret.numOfFailed=resultObj.NumFailedIterations;
        ret.numOfDisabled=resultObj.NumDisabledIterations;
        ret.numOfIncomplete=resultObj.NumIncompleteIterations;
    else
        ret.numOfResults=1;
        ret.numOfPassed=(outcome==sltest.testmanager.TestResultOutcomes.Passed);
        ret.numOfFailed=(outcome==sltest.testmanager.TestResultOutcomes.Failed);
        ret.numOfDisabled=(outcome==sltest.testmanager.TestResultOutcomes.Disabled);
        ret.numOfIncomplete=(outcome==sltest.testmanager.TestResultOutcomes.Incomplete);
    end
end
