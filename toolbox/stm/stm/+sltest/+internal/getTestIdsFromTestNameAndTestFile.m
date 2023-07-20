function testIds=getTestIdsFromTestNameAndTestFile(testName,testFile)




    [~,testFileName,~]=sltest.internal.getSuiteFromTestPath(testFile);
    if strcmp(testFileName,testName)
        testIds=stm.internal.getTestIdFromTestNameAndTestFile(testName,testFile,false);
    else
        suites=matlab.unittest.TestSuite.fromFile(testFile,'ProcedureName',testName);
        testIds=int32.empty(0,length(suites));
        for idx=1:length(suites)
            testIds(idx)=stm.internal.getTestIdFromTestNameAndTestFile(suites(idx).Name,testFile,true);
        end
    end
    if isempty(testIds)
        testIds=int32(0);
    end
end