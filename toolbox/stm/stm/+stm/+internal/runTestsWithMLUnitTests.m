



function runTestsWithMLUnitTests(testFilePath,testHierarchyUnderTestFile,testCaseName,resultSetID,testCaseResultID,testCaseID)

    try
        runner=matlab.unittest.TestRunner.withNoPlugins;

        [selectedSuiteElement,fileName]=sltest.internal.getScriptedSelectedTestElement(testFilePath,testHierarchyUnderTestFile);



        if isequal(size(selectedSuiteElement),[1,1])



            tcResultsHolder=sltest.internal.TestCaseResultsHolder(selectedSuiteElement.Name);
            tcResultsHolder.TestCaseID=testCaseID;
            tcResultsHolder.TestCaseResultsID=testCaseResultID;




            fixture=sltest.internal.testmanager.fixtures.ResultSetFixture(sltest.internal.ResultSetLiaison.getResultSetHolder());
            fixture.setResultSetID(resultSetID);
            cleanResultSetID=onCleanup(@()fixture.clearResultSetID());

            runner.PrebuiltFixtures=fixture;

            scriptedPlugin=sltest.plugins.MATLABTestCaseIntegrationPlugin(...
            'TestCaseResultsHolder',tcResultsHolder);


            streamOutput=sltest.plugins.ToTestManagerLog();
            diagnosticsOutputPlugin=matlab.unittest.plugins.DiagnosticsOutputPlugin(streamOutput,'IncludingPassingDiagnostics',true);

            runner.addPlugin(scriptedPlugin);
            runner.addPlugin(diagnosticsOutputPlugin);

            runner.run(selectedSuiteElement);

        else
            stm.internal.setTestCaseResultMessages(testCaseID,testCaseResultID,resultSetID,...
            message('stm:ScriptedTest:OutOfSync',testCaseName,fileName).getString(),true);
        end
    catch ME
        stm.internal.setTestCaseResultMessages(testCaseID,testCaseResultID,resultSetID,...
        ME.message,true);
    end
end
