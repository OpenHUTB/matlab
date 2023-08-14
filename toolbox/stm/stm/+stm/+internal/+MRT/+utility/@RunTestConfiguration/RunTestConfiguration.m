classdef RunTestConfiguration<stm.internal.RunTestConfiguration





    properties
        runCallbacks=false;
    end

    methods
        function obj=RunTestConfiguration()
            obj@stm.internal.RunTestConfiguration('');
            obj.runCallbacks=false;
        end

        function val=runUsingSimIn(~)
            val=false;
        end

        function updateTestCaseSpinnerLabel(~,~,~)

        end

        function applySignalLoggingForAssessments(obj,assessmentSignals,simWatcher)
            import stm.internal.RunTestConfiguration.*
            if~isempty(assessmentSignals)
                if~isempty(obj.testSettings.signalLogging)
                    bFromIteration=obj.testSettings.signalLogging.fromIteration;
                else
                    bFromIteration=false;
                end
                configureSignalsForStreamingHelper(assessmentSignals,...
                bFromIteration,obj.modelToRun,simWatcher);
            end
        end

        [result,streamedRunID,sigLoggingName,outportName,verifyResult]=...
        simulate(obj,...
        simInputs,simWatcher,...
        inputDataSetsRunFile,inputSignalGroupRunFile);
    end

    methods(Static)
        getAssessmentsData(simInputs,signalLoggingOn,sigLoggingName,obj)
        cachedSignals=cacheConstSignalIndices(simOut,outLoggingName,sigLoggingName);
        discreteEventSignalDataSet=cacheDiscreteEventSignalPorts();
    end
end
