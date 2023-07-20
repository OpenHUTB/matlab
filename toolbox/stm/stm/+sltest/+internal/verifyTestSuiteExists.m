function tf=verifyTestSuiteExists(testPath,expectedSuiteName)




    [~,suiteNames]=sltest.internal.getSuiteFromTestPath(testPath);
    suiteNameMask=strcmp(expectedSuiteName,suiteNames);
    tf=any(suiteNameMask);
end
