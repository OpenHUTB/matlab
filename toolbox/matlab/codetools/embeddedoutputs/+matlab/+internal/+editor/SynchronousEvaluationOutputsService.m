classdef(Hidden)SynchronousEvaluationOutputsService<handle

    properties
        BatchedOutputs=[];
        EvalEndData=[];
    end

    properties(Constant)
        EVAL_END_MESSAGE_PREFIX='SENT_EVAL_END_FOR_';
        OUTPUT_STREAM_END_MESSAGE_PREFIX='SENT_OUTPUT_STREAMING_END_FOR_';
    end

    methods(Static)
        function[evaluationResult,cleanupObj]=evaluateSynchronously(editorId,requestId,regionList,fullText,filePath)
            synchronousEvaluationOutputsService=matlab.internal.editor.SynchronousEvaluationOutputsService();
            [evaluationResult,cleanupObj]=synchronousEvaluationOutputsService.evalRegions(editorId,requestId,regionList,fullText,filePath);
            delete(synchronousEvaluationOutputsService)
        end
    end

    methods(Access=public,Hidden)

        function obj=SynchronousEvaluationOutputsService()
            obj.BatchedOutputs=[];
        end

        function[evaluationResult,cleanupObj]=evalRegions(obj,editorId,requestId,regionListJSON,fullText,filePath)












            import matlab.internal.editor.*;



            regionList=mls.internal.fromJSON(regionListJSON);

            EODataStore.setRootField('SynchronousOutput',true);
            settingsObj=settings;
            settingsObj.matlab.editor.AllowFigureAnimation.TemporaryValue=0;
            cleanupObj.AllowAnimations=onCleanup(@()settingsObj.matlab.editor.AllowFigureAnimation.clearTemporaryValue);

            try
                evaluateRegions(editorId,requestId,regionList,fullText,true,true,filePath,-1,...
                [],...
                [],...
                @(src,ev)obj.outputStreamEvent(src,ev,editorId,requestId,filePath),...
                @(src,ev)obj.evaluationEnded(src,ev,editorId,requestId),...
                [],...
                false);
            catch e

                obj.sendException(e);
            end

            EODataStore.setRootField('SynchronousOutput',false);
            evaluationResult.outputs=obj.BatchedOutputs;
            evaluationResult.evalEndData=obj.EvalEndData;
            evaluationResult.requestId=requestId;

            cleanupObj.evalCleanup=onCleanup(@()obj.evaluationCleanup(editorId,requestId));
            cleanupObj.fullCleanup=onCleanup(@()obj.cleanup(editorId));
        end

        function outputStreamEvent(obj,~,ev,editorId,requestId,fullFileName)


            import matlab.internal.editor.SynchronousEvaluationOutputsService
            import matlab.internal.editor.OutputPackager

            try
                outputs=OutputPackager.packageEachOutput(editorId,requestId,fullFileName,ev.BatchedOutputEvents);
                obj.BatchedOutputs=[obj.BatchedOutputs;outputs];
            catch e

                obj.sendException(e);
            end
        end

        function evaluationEnded(obj,~,ev,~,~)
            obj.EvalEndData.didRunToCompletion=ev.DidRunToCompletion;
            obj.EvalEndData.errorType=ev.ErrorType;
        end

        function evaluationCleanup(~,editorId,requestId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.SynchronousEvaluationOutputsService
            import matlab.internal.editor.OutputUtilities

            EODataStore.clearEditorField(editorId,[SynchronousEvaluationOutputsService.EVAL_END_MESSAGE_PREFIX,requestId])
            EODataStore.clearEditorField(editorId,[SynchronousEvaluationOutputsService.OUTPUT_STREAM_END_MESSAGE_PREFIX,requestId])



            OutputUtilities.clearCache();
        end

        function cleanup(obj,editorId)

            import matlab.internal.editor.SynchronousEvaluationOutputsService
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.VariableManager
            import matlab.internal.editor.interactiveVariables.InteractiveVariablesPackager
            import matlab.internal.editor.eval.TmpFilePath

            TmpFilePath.delete(editorId);

            InteractiveVariablesPackager.clearVariableEditorOutputs(editorId);
            VariableManager.clearAll(editorId);
            FigureManager.closeAllEditorFigures(editorId);
            FigureManager.cleanupAfterEval(editorId);
            FigureManager.disableCaptureFigures(editorId);
            FigureManager.destroyAllEditorFigureData(editorId);
            FigureManager.cleanupOnEditorClose(editorId);
            EODataStore.removeEditorMap(editorId);
        end

        function clearOutputsCache(~,editorId)

            import matlab.internal.editor.VariableManager;
            import matlab.internal.editor.FigureManager;

            VariableManager.clearAll(editorId);
            FigureManager.clearFigures(editorId);
        end

        function throwOutOfMemoryException(exceptionMessage)



            throw(MException('LiveEditor:OutOfMemory',exceptionMessage));
        end

        function sendException(~,exception)

            if~isempty(exception)
                exception.rethrow();
            end
        end

    end
end
