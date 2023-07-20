function testFileID=createScriptedTestFile(testPath,isValid,testFileID)




    [suite,testFileName,suiteNames]=sltest.internal.getSuiteFromTestPath(testPath);

    if~isValid
        testFileID=stm.internal.createScriptedTestFile(testPath,testFileName);
    end

    for suiteNameIndex=1:length(suiteNames)
        classSetupParameters=getSetupParameterization(suiteNames{suiteNameIndex});
        if~isempty(classSetupParameters)
            testClassSuiteID=stm.internal.createScriptedTestSuite(testFileID,classSetupParameters,int32(1));
        else
            testClassSuiteID=testFileID;
        end
        for suiteIndex=1:length(suite)
            thisSuiteName=regexp(suite(suiteIndex).Name,'^[^/]+','match');
            if strcmp(thisSuiteName,suiteNames(suiteNameIndex))
                [testCaseName,methodSetupParameters]=getTestCaseNameAndMethodParameterName(suite(suiteIndex).Name);
                if~isempty(methodSetupParameters)
                    testMethodSuiteID=stm.internal.createScriptedTestSuite(testClassSuiteID,methodSetupParameters,int32(2));
                else
                    testMethodSuiteID=testClassSuiteID;
                end
                testCaseID=stm.internal.createScriptedTestCase(testMethodSuiteID,testCaseName);%#ok<NASGU>
            end
        end
    end

end
function[testCaseName,methodSetupParameters]=getTestCaseNameAndMethodParameterName(suiteName)
    remainingSuiteName=regexprep(suiteName,'^[^/]+/','');
    methodSetupParameters=getSetupParameterization(remainingSuiteName);
    if~isempty(methodSetupParameters)
        testCaseName=regexp(remainingSuiteName,'(?<=\]).+','match');
        testCaseName=[testCaseName{:}];
    else
        testCaseName=remainingSuiteName;
    end
end
function setupParameterizationName=getSetupParameterization(elementName)
    setupParameterizationName=regexp(elementName,'\[[^(\[\])]+\]','match');
    setupParameterizationName=[setupParameterizationName{:}];
end

