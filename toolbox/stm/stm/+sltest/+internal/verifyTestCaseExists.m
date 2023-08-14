function tf=verifyTestCaseExists(testPath,expTestCaseName)




    [suite,fileName,~]=sltest.internal.getSuiteFromTestPath(testPath);
    suiteMask=arrayfun(@(x)isequal(x.Name,[fileName,expTestCaseName]),suite);
    tf=any(suiteMask);
end
