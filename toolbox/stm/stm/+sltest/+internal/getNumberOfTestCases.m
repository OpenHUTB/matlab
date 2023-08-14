function numTestCases=getNumberOfTestCases(testPath)




    suite=matlab.unittest.TestSuite.fromFile(testPath);
    numTestCases=length(suite);
end
