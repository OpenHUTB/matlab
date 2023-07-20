classdef STMCustomCriteria<matlab.unittest.TestCase




    properties(SetAccess=private)
        TestResult;
        sltest_simout;
        sltest_testCase;
        sltest_bdroot;
        sltest_sut;
        sltest_isharness;
        sltest_iterationName;
    end

    properties(Hidden)
        Callback;
    end

    methods(Test)
        function defaultCurrentPoint(test)
            TestResult=test.TestResult;%#ok<NASGU,PROP>
            sltest_simout=test.sltest_simout;%#ok<NASGU,PROP>
            sltest_testCase=test.sltest_testCase;%#ok<NASGU,PROP>
            sltest_bdroot=test.sltest_bdroot;%#ok<NASGU,PROP>
            sltest_sut=test.sltest_sut;%#ok<NASGU,PROP>
            sltest_isharness=test.sltest_isharness;%#ok<NASGU,PROP>
            sltest_iterationName=test.sltest_iterationName;%#ok<NASGU,PROP>
            eval(test.Callback);
        end
    end

    methods(Static)
        function result=evalCustomCriteria(callback,ccInput,includePassingDiagnostics)
            import sltest.internal.STMCustomCriteria;

            cc=sltest.internal.STMCustomCriteria;
            cc.Callback=callback;
            if isempty(ccInput.sltest_iterationName)
                cc.TestResult=sltest.testmanager.TestCaseResult(ccInput.testCaseResultID);
            else
                cc.TestResult=sltest.testmanager.TestIterationResult(ccInput.testCaseResultID);
            end
            cc.sltest_simout=STMCustomCriteria.getSimOut(ccInput.sltest_simout);
            cc.sltest_testCase=sltest.testmanager.TestCase([],ccInput.testCaseID);
            cc.sltest_bdroot=ccInput.sltest_bdroot;
            cc.sltest_sut=ccInput.sltest_sut;
            cc.sltest_isharness=ccInput.sltest_isharness;
            cc.sltest_iterationName=ccInput.sltest_iterationName;
            result=STMCustomCriteria.runner(cc,includePassingDiagnostics);
        end

        function result=runner(customCriteria,includePassingDiagnostics)
            import matlab.unittest.plugins.DiagnosticsRecordingPlugin;
            runner=matlab.unittest.TestRunner.withNoPlugins;
            p=DiagnosticsRecordingPlugin('IncludingPassingDiagnostics',includePassingDiagnostics);
            runner.addPlugin(p);
            test=matlab.unittest.Test.fromTestCase(customCriteria);
            result=runner.run(test);
        end

        function simOut=getSimOut(simOut)
            if numel(simOut)==2
                simOut=[simOut{1},simOut{2}];
            elseif numel(simOut)==1
                simOut=simOut{1};
            end
        end
    end
end
