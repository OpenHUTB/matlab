function[selectedSuiteElement,fileName]=getScriptedSelectedTestElement(testPath,testName)




    [suite,fileName]=sltest.internal.getSuiteFromTestPath(testPath);

    suiteMask=strcmp([fileName,testName],{suite.Name});
    if~any(suiteMask)
        suiteMask=strcmp([fileName,'/',testName],{suite.Name});
    end

    if~any(suiteMask)
        parsedTestName=regexp(testName,'(^[^\]]+\])(.*)','tokens');
        parsedTestName=[parsedTestName{:}];
        testName=join(string(parsedTestName),"/");
        suiteMask=strcmp([fileName,char(testName)],{suite.Name});
    end

    selectedSuiteElement=suite(suiteMask);
end
