function output=parseTestSuiteExternalMFile(path)

    tests=testsuite(path);
    testSuiteName=tests(1).TestClass;
    output(1,1)=testSuiteName;
    for i=1:length(tests)
        testCaseName=tests(i).ProcedureName;
        output(i+1,1)=testCaseName;
    end

end