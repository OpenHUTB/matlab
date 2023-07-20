


function coverageSettings=getCoverageSettings(callingFunction,testId)
    if strcmp(callingFunction,'captureSimOut')
        testId=-1;
    end
    coverageSettings=sltest.internal.Helper.getCoverageSettings(...
    testId,false);
end
