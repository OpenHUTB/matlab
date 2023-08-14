classdef(Sealed)Feature<experiments.internal.JSServiceFeature




    properties(SetAccess={?experiments.internal.JSServiceFeature})
        mockTrainNetwork function_handle{mustBeScalarOrEmpty}=function_handle.empty;
        mockStopExperiment(1,1)logical=false;
        showKeywordsFilter(1,1)logical=false;
        captureWorkerInfo(1,1)logical=false;
        batchExecution(1,1)logical=true;
        trainingPlotterThrottleRate(1,1)double=1;
        startPageAndExperimentTemplates(1,1)logical=true;
        annotations(1,1)logical=true;
        annotationsSorting(1,1)logical=true;
        useRegFrwk(1,1)logical=true;
        createMFiles(1,1)logical=false;
        matlabOnline(1,1)logical=true;
        showROCCurve(1,1)logical=false;
        alwaysUseFileChooser(1,1)logical=false;
        exportToEM(1,1)logical=true;
        restartAllTrials(1,1)logical=true;
        g2483536Workaround(1,1)logical=false;
        executionEnvironment(1,1)logical=true;
        vizGallery(1,1)logical=true;
        advancedBayesoptOptions(1,1)logical=false;
    end

    methods(Access=private)
        function delete(~)

        end
    end
end
