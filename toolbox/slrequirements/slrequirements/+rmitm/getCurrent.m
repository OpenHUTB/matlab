function[testFile,testCaseId,testCaseLabel]=getCurrent()
    [testFile,testCaseId,~]=stm.internal.util.getCurrentTestCase();
    testCaseLabel=stm.internal.getTestCaseNameFromUUIDAndTestFile(testCaseId,testFile);
end