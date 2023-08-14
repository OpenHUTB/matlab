classdef(Abstract,SharedTestFixtures={sltest.internal.testmanager.fixtures.ResultSetFixture(...
    sltest.internal.ResultSetLiaison.getResultSetHolder)})...
    TestCase<simulinktest.internal.TestCase&...
    sltest.qualifications.Verifiable&...
    sltest.qualifications.Assumable&...
    sltest.qualifications.Assertable&...
    sltest.qualifications.FatalAssertable



























    methods(Static)
        function testCase=forInteractiveUse(varargin)

















            testCase=sltest.InteractiveTestCase(varargin{:});
        end
    end
    methods(TestMethodSetup)
        function createSTMTestResult(testCase)



            testCase.applyFixture(sltest.internal.TestCaseResultsFixture(...
            sltest.internal.ResultSetLiaison.getResultSetHolder,...
            sltest.internal.ResultSetLiaison.getTestCaseResultsHolder));
        end
    end

    methods(TestMethodTeardown)
        function teardownSTMTest(testCase)
            if~isempty(sltest.internal.ResultSetLiaison.getResultSetHolder)
                if~isempty(sltest.internal.ResultSetLiaison.getResultSetHolder.ResultSetID)
                    testCase.publish("sltest:testmanager:resultsetid",sltest.internal.ResultSetLiaison.getResultSetHolder.ResultSetID);
                    testCase.publish("sltest:testmanager:resultsetholder",sltest.internal.ResultSetLiaison.getResultSetHolder);
                end
            end

            if~isempty(sltest.internal.ResultSetLiaison.getTestCaseResultsHolder)
                if~isempty(sltest.internal.ResultSetLiaison.getTestCaseResultsHolder.TestCaseResultsID)
                    tcResultsID=sltest.internal.ResultSetLiaison.getTestCaseResultsHolder.TestCaseResultsID;
                    tcResults=sltest.testmanager.TestResult.getResultFromID(tcResultsID);
                    testCase.publish(sltest.internal.resultsCommunicationChannel,tcResults);
                end
            end
        end
    end

    methods(Sealed)
        function simOut=simulate(testCase,source,varargin)












































            import sltest.internal.constraints.TestAssessmentPasses

            p=inputParser;
            p.addParameter('InFolder',pwd,@ischar);
            p.addParameter('WithHarness',[],@validateHarness);
            p.KeepUnmatched=true;
            p.parse(varargin{:});

            simulationFolder=p.Results.InFolder;

            simulationParameters=interleaveNameValuePairs(fieldnames(p.Unmatched),struct2cell(p.Unmatched));

            currFigs=stm.internal.artifacts.getNewFigures();
            origDir=pwd;
            cleanDir=onCleanup(@()cd(origDir));
            cd(simulationFolder);

            if~isa(source,'Simulink.SimulationInput')
                source=testCase.createSimulationInput(source,varargin{:});
            else
                if numel(source)>1
                    error(message('stm:ScriptedTest:SimulationInputArray'));
                end
                testCase.loadSystem(source.ModelName);
            end
            testCase.validateModelIsNotHarness(source.ModelName,'simulate');

            if isa(source,'sltest.harness.SimulationInput')

                harnessInfo=Simulink.harness.find(source.HarnessOwner,'Name',source.HarnessName);
                if~isempty(harnessInfo)&&~harnessInfo.isOpen
                    source.loadHarness();
                    cleanHarness=onCleanup(@()source.closeHarness());
                end
            end

            simulationInputLiaison=sltest.internal.SimulationInputLiaison(source,simulationParameters{:},'CaptureErrors','on');



            originalState=warning("off","Stateflow:Runtime:TestVerificationFailed");
            restoreWarnings=onCleanup(@()warning(originalState));

            testCase.publish("sltest:testmanager:preSimConfiguration",simulationInputLiaison);
            simOut=sim(simulationInputLiaison.SimulationInput);
            resultsLiaison=sltest.internal.STMResultsLiaison(simOut,simulationInputLiaison.SimulationInput,currFigs);
            testCase.publish("sltest:testmanager:postSimConfiguration",resultsLiaison);
            testCase.publish("sltest:testmanager:pushSimulationResults",resultsLiaison);

            if~isempty(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic)
                me=simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic;
                reportAsError(me);
            end

            if hasTestAssessment(source)
                simulationInfo=struct('simOut',simOut,'source',source);
                testCase.verifyThat(simulationInfo,TestAssessmentPasses);
            end
        end
        function simulationInput=createSimulationInput(testCase,system,varargin)







































            p=inputParser;
            p.addRequired('System',@validateSystem);
            p.addParameter('WithHarness',[],@validateHarness);
            p.KeepUnmatched=true;
            p.parse(system,varargin{:});

            creator=sltest.internal.simulation.SimulationInputCreatorFactory.getCreator(...
            p.Results.System,p.Results.WithHarness);
            testCase.loadSystem(creator.Model);
            testCase.validateModelIsNotHarness(creator.Model,'createSimulationInput');
            simulationInput=creator.create();
        end
    end
    methods(Access=private)
        function validateModelIsNotHarness(~,modelName,methodName)
            if Simulink.harness.isHarnessBD(modelName)
                throw(MException(message('stm:ScriptedTest:HarnessModelInvalidUsage',methodName)));
            end
        end
    end

end

function parameters=interleaveNameValuePairs(names,values)

    parameters=cell.empty;
    if isempty(names)
        return
    end

    parameters=cell(1,2*numel(names));
    parameters(1:2:end)=names;
    parameters(2:2:end)=values;
end
function validateSystem(system)
    validateSimInputArgs(system,'System');
end
function validateHarness(harness)
    validateSimInputArgs(harness,'Harness');
end
function validateSimInputArgs(simInputArgs,paramName)
    if isstring(simInputArgs)
        simInputArgs=convertStringsToChars(simInputArgs);
    end
    validateattributes(simInputArgs,{'char'},{'nonempty'},'',paramName);
end

function bool=hasTestAssessment(source)
    engine=Simulink.sdi.Instance.engine();
    model=source.getModelNameForApply;
    modelHandle=get_param(model,'Handle');
    runID=engine.getCurrentStreamingRunIDByHandle(modelHandle);
    bool=(runID>0)&&stm.internal.hasVerifySignal(runID);
end

