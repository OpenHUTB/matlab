classdef MATLABTestCaseIntegrationPlugin<matlab.unittest.plugins.TestRunnerPlugin
























































    properties(Constant,Access=private)
        STMResultsChannel="sltest:testmanager:pushSimulationResults";
        DetailsLabel=sltest.internal.plugins.getResultDetailsLabel();
    end
    properties(Access=private)
        TestFile sltest.testmanager.TestFile;
        TestCaseResultsMap containers.Map
        TestCaseResultsHolder sltest.internal.TestCaseResultsHolder;
    end

    methods
        function plugin=MATLABTestCaseIntegrationPlugin(varargin)
            parser=matlab.unittest.internal.strictInputParser;
            parser.addParameter('TestCaseResultsHolder',sltest.internal.TestCaseResultsHolder.empty);
            parser.parse(varargin{:});
            plugin.TestCaseResultsHolder=parser.Results.TestCaseResultsHolder;
        end
    end
    methods(Access=protected)
        function runTestSuite(plugin,pluginData)

            plugin.TestCaseResultsMap=containers.Map;
            cleanTestIDs=onCleanup(@()plugin.flushTestCaseAndTestSuiteIDs);
            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);
        end
        function runTestClass(plugin,pluginData)
            filePath=which(pluginData.Name);
            if~isempty(filePath)
                isScriptedTest=isa(feval(pluginData.Name),'sltest.TestCase');
                if isempty(plugin.TestCaseResultsHolder)&&isScriptedTest
                    plugin.TestFile=sltest.testmanager.load(filePath);
                end
            end
            runTestClass@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);
        end
        function runTest(plugin,pluginData)
            runTest@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);
            emptyTestCaseResultsHolder=sltest.internal.TestCaseResultsHolder.empty;
            cleanTestCaseResultHolder=onCleanup(@()sltest.internal.ResultSetLiaison.usingTestCaseResultsHolder(emptyTestCaseResultsHolder));
        end
        function testCase=createTestMethodInstance(plugin,pluginData)
            testCase=createTestMethodInstance@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);



            if isempty(plugin.TestCaseResultsHolder)&&~isempty(plugin.TestFile)
                stmTestCase=getSTMTestCase(plugin,pluginData);
                tcResultsHolder=sltest.internal.TestCaseResultsHolder(pluginData.Name);
                tcResultsHolder.TestCaseID=stmTestCase.getID();
                tcResultsHolder.TestFileID=plugin.TestFile.getID();
            else
                tcResultsHolder=plugin.TestCaseResultsHolder;
            end




            if isempty(sltest.internal.ResultSetLiaison.usingTestCaseResultsHolder)


                testCase.subscribe(plugin.STMResultsChannel,@(resultsLiaison)plugin.pushSTMResults(resultsLiaison));
            end
            sltest.internal.ResultSetLiaison.usingTestCaseResultsHolder(tcResultsHolder);
        end
        function setupTestMethod(plugin,pluginData)
            setupTestMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);


            tcrHolder=sltest.internal.ResultSetLiaison.getTestCaseResultsHolder;
            if~isempty(tcrHolder)
                if tcrHolder.areIDsPopulated()
                    plugin.TestCaseResultsMap(pluginData.Name)=[...
                    sltest.internal.ResultSetLiaison.getTestCaseResultsHolder.TestCaseID
                    sltest.internal.ResultSetLiaison.getTestCaseResultsHolder.TestCaseResultsID
                    sltest.internal.ResultSetLiaison.getResultSetHolder.ResultSetID];
                    tcResults=sltest.testmanager.TestResult.getResultFromID(...
                    sltest.internal.ResultSetLiaison.getTestCaseResultsHolder.TestCaseResultsID);
                    resultDetailsAccessor=pluginData.ResultDetails;
                    resultDetailsAccessor.replace(plugin.DetailsLabel,tcResults);
                end
            end
        end
        function reportFinalizedResult(plugin,pluginData)
            if any(ismember(keys(plugin.TestCaseResultsMap),pluginData.Name))
                testMapInfo=plugin.TestCaseResultsMap(pluginData.Name);
                testCaseID=testMapInfo(1);
                testCaseResultID=testMapInfo(2);
                resultSetID=testMapInfo(3);

                stm.internal.setTestCaseResult(testCaseID,testCaseResultID,...
                resultSetID,...
                pluginData.TestResult.Passed);
            end
            reportFinalizedResult@matlab.unittest.plugins.TestRunnerPlugin(plugin,pluginData);
        end
    end
    methods(Access=private)
        function pushSTMResults(plugin,resultsLiaison)
            rsHolder=sltest.internal.ResultSetLiaison.getResultSetHolder;
            tcrHolder=sltest.internal.ResultSetLiaison.getTestCaseResultsHolder;
            plugin.setTestCaseProperties(tcrHolder.TestCaseID,resultsLiaison.Results);

            if~isempty(resultsLiaison.Results.RunID)&&resultsLiaison.Results.RunID~=0
                Simulink.sdi.internal.moveRunToApp(resultsLiaison.Results.RunID,'STM');
            end
            stm.internal.pushResults(tcrHolder.TestCaseID,tcrHolder.TestCaseResultsID,...
            rsHolder.ResultSetID,resultsLiaison.Results);
        end
        function setTestCaseProperties(~,tcId,results)
            testCase=sltest.testmanager.Test.getTestObjFromID(tcId);
            simMode=results.simMode;
            if strcmp(simMode,'rapid-accelerator')
                simMode='rapid accelerator';
            end

            testCase.setProperty('Model',results.mainModel);
            testCase.setProperty('SimulationMode',simMode);
            if~isequal(results.mainModel,results.modelToRun)
                testCase.setProperty('HarnessName',results.modelToRun,...
                'HarnessOwner',results.harnessOwner);
            end
        end
        function flushTestCaseAndTestSuiteIDs(plugin)
            plugin.TestCaseResultsMap=containers.Map;
            plugin.TestFile=sltest.testmanager.TestFile.empty;
        end
        function stmTestCase=getSTMTestCase(plugin,pluginData)
            splitTestName=split(pluginData.Name,{'/','[',']'});
            splitTestName=splitTestName(~cellfun('isempty',splitTestName));
            for idx=2:length(splitTestName)-1
                splitTestName(idx)=strcat('[',splitTestName(idx),']');
            end
            testSuite=plugin.TestFile;
            for idx1=2:length(splitTestName)-1
                testSuite=testSuite.getTestSuiteByName(splitTestName{idx1});
            end
            stmTestCase=testSuite.getTestCaseByName(splitTestName{end});
        end
    end
end



