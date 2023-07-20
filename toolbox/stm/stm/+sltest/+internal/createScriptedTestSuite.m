function testSuiteID=createScriptedTestSuite(testPath,isValid,testSuiteID)




    [suite,suiteNames]=sltest.internal.getSuiteFromTestPath(testPath);
    for suiteNameIndex=1:length(suiteNames)
        if~isValid
            testSuiteID=stm.internal.createScriptedTestSuite(testPath,suiteNames{suiteNameIndex});
        end
        for suiteIndex=1:length(suite)
            thisSuiteName=regexp(suite(suiteIndex).Name,'^[^/]+','match');
            if strcmp(thisSuiteName,suiteNames(suiteNameIndex))
                testCaseName=regexprep(suite(suiteIndex).Name,'^[^/]+/','');
                testCaseID=stm.internal.createScriptedTestCase(testSuiteID,testCaseName);%#ok<NASGU>
            end
        end
    end

end
