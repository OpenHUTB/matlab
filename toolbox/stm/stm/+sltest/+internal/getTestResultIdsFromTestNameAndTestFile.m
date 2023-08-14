function resultIds=getTestResultIdsFromTestNameAndTestFile(testName,testFile)




    [~,testFileName,~]=sltest.internal.getSuiteFromTestPath(testFile);
    if strcmp(testFileName,testName)
        resultIds=stm.internal.getTestResultIdFromTestNameAndTestFile(testName,testFile);
    else
        suites=matlab.unittest.TestSuite.fromFile(testFile,'ProcedureName',testName);
        resultIds=int32.empty(0,length(suites));
        for idx=1:length(suites)
            resultIds(idx)=stm.internal.getTestResultIdFromTestNameAndTestFile(suites(idx).Name,testFile);
        end
    end
    if isempty(resultIds)
        resultIds=int32(0);
    end
end
