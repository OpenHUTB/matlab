classdef(Hidden)EvaluationOutputsService


    properties(Constant)
        REGION_EVAL_START='/liveEval/regionEvaluating/';
        SECTION_EVAL_END='/liveEval/sectionEvaled/';
        REGIONS_EVAL_END='/liveEval/regionsEvaled/';
        OUTPUT_STREAM_EVENT='/embeddedOutputs/outputStreamEvent/';
        OUTPUT_STREAM_STATUS='/embeddedOutputs/outputStreamStatus/';
        EVAL_END_MESSAGE_PREFIX='SENT_EVAL_END_FOR_';
        OUTPUT_STREAM_END_MESSAGE_PREFIX='SENT_OUTPUT_STREAMING_END_FOR_';

        GLOBAL_EVAL_STARTED='/liveeditor/evaluation/eval-started';
        GLOBAL_EVAL_ENDED='/liveeditor/evaluation/eval-ended';
        FILE_EVAL_STARTED='/execution/startingEvaluation/';
        FILE_EVAL_ENDED='/execution/endingEvaluation/';
    end

    methods(Static)

        function prewarmExecution(editorId,emptyFileRegionListJSON)
            import matlab.internal.editor.*;
            import matlab.internal.editor.debug.*;
            import matlab.internal.editor.interactiveVariables.*;

            if matlab.internal.editor.PrewarmingSuppressor.isPrewarmingSuppressed()
                return;
            end

            connector.ensureServiceOn;

            if nargin==1
                emptyFileRegionListJSON='{"regionLineNumber":1, "regionString":";","regionNumber":1,"endOfSection":true,"sectionNumber":1,"regionUid":""}';
            end



            emptyFileRegionList=mls.internal.fromJSON(emptyFileRegionListJSON);

            matlab.internal.editor.ExecutionStateTracker.notifyEditorClose('');


            cleanupObj=DebugUtilities.disableBreakpoints();%#ok<NASGU>



            evaluateRegions(editorId,'prewarm',emptyFileRegionList,';',false,true,'',-1,[],[],[],[],[],true);


            SO=OutputPackager;
            EOSU=EvaluationOutputsServiceUtilities;
            OU=OutputUtilities;
            VariableUtilities.getHeader('OU');
            IVP=InteractiveVariablesPackager;


            matlab.internal.editor.figure.FigurePoolManager.createPoolWhenMLIsIdle(editorId);
        end








        function evalRegions(editorId,requestId,regionListJSON,fullText,shouldResetState,isSavedFile,filePath,lastDocumentState,customExecutionDataJSON)
















            import matlab.internal.editor.*;

            prewarmingSuppressor=matlab.internal.editor.PrewarmingSuppressor;%#ok<NASGU>

            connector.ensureServiceOn;

            try
                cleanupObj=EvaluationOutputsService.setupForEvaluation(editorId,fullText);%#ok<NASGU>

                matlab.internal.editor.ExecutionStateTracker.notifyExecutionStarted(editorId,requestId);



                regionList=mls.internal.fromJSON(regionListJSON);
                shouldUseTempFile=EvaluationOutputsServiceUtilities.shouldUseTempFile(isSavedFile,filePath);


                if nargin<9
                    customExecutionDataJSON='';
                end
                EvaluationOutputsServiceUtilities.processCustomExecutionData(customExecutionDataJSON);

                evaluateRegions(editorId,requestId,regionList,fullText,shouldResetState,shouldUseTempFile,filePath,lastDocumentState,...
                @(src,ev)EvaluationOutputsService.regionEvalStarted(src,ev,editorId,requestId),...
                @(src,ev)EvaluationOutputsService.sectionEvalEnded(src,ev,editorId,requestId),...
                @(src,ev)EvaluationOutputsService.outputStreamEvent(src,ev,editorId,requestId,filePath),...
                @(src,ev)EvaluationOutputsService.evaluationEnded(src,ev,editorId,requestId),...
                @(~,~)EvaluationOutputsService.outputStreamingEnded(editorId,requestId),...
                false);

                cleanupObj=[];
            catch e

                EvaluationOutputsService.sendException(e);
            end
        end

        function cleanupObj=setupForEvaluation(editorId,fullText)

            cleanupObj=struct();


            cleanupObj.endEvalState=onCleanup(@()message.publish([matlab.internal.editor.EvaluationOutputsService.FILE_EVAL_ENDED,editorId],[]));
            message.publish([matlab.internal.editor.EvaluationOutputsService.FILE_EVAL_STARTED,editorId],[]);


            if usejava('jvm')
                cleanupObj.setIdle=onCleanup(@()com.mathworks.mde.embeddedoutputs.RegionEvaluator.markEditorAsDoneExecuting());
                com.mathworks.mde.embeddedoutputs.RegionEvaluator.markEditorAsExecuting();
            end

            cleanupObj.publishEvalEnded=onCleanup(@()message.publish(matlab.internal.editor.EvaluationOutputsService.GLOBAL_EVAL_ENDED,1));
            message.publish(matlab.internal.editor.EvaluationOutputsService.GLOBAL_EVAL_STARTED,1);
        end

        function regionEvalStarted(~,eventData,editorId,requestId)



            import matlab.internal.editor.EvaluationOutputsService
            regionNumber=eventData.RegionNumber;

            try
                message.publish([EvaluationOutputsService.REGION_EVAL_START,editorId],regionNumber-1);
            catch e

                EvaluationOutputsService.sendException(e);
            end
        end

        function outputStreamEvent(~,ev,editorId,requestId,fullFileName)


            import matlab.internal.editor.EvaluationOutputsService
            import matlab.internal.editor.OutputPackager

            try

                outputsMessage=OutputPackager.packageOutputs(...
                editorId,requestId,fullFileName,ev.BatchedOutputEvents,...
                ev.CompletedRegionNumbers);

                outputsMessage.batchId=matlab.internal.editor.ExecutionStateTracker.getNextOutputBatchId(editorId);
                message.publish([EvaluationOutputsService.OUTPUT_STREAM_EVENT,editorId],outputsMessage);
                matlab.internal.editor.ExecutionStateTracker.notifyOutputBatchSent(editorId);
            catch e

                EvaluationOutputsService.sendException(e);
            end
        end

        function outputStreamingEnded(editorId,requestId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.EvaluationOutputsService
            import matlab.internal.editor.OutputUtilities

            try


                OutputUtilities.clearCache();
                alreadySent=EODataStore.getEditorField(editorId,[EvaluationOutputsService.OUTPUT_STREAM_END_MESSAGE_PREFIX,requestId]);
                if isempty(alreadySent)
                    lastBatchId=matlab.internal.editor.ExecutionStateTracker.getLastOutputBatchId(editorId,requestId);
                    message.publish([EvaluationOutputsService.OUTPUT_STREAM_STATUS,editorId],...
                    struct('streamingFinished',true,'lastOutputBatchId',lastBatchId));
                    EODataStore.setEditorField(editorId,[EvaluationOutputsService.OUTPUT_STREAM_END_MESSAGE_PREFIX,requestId],true);
                end
            catch e

                EvaluationOutputsService.sendException(editorId,requestId,e);
            end
        end

        function sectionEvalEnded(~,ev,editorId,requestId)


            import matlab.internal.editor.EvaluationOutputsService

            try
                message.publish([EvaluationOutputsService.SECTION_EVAL_END,editorId],ev.SectionNumber);
            catch e

                EvaluationOutputsService.sendException(e);
            end
        end

        function evaluationEnded(~,ev,editorId,requestId)
            import matlab.internal.editor.EvaluationOutputsService
            import matlab.internal.editor.EODataStore

            try
                alreadySent=EODataStore.getEditorField(editorId,[EvaluationOutputsService.EVAL_END_MESSAGE_PREFIX,requestId]);
                if isempty(alreadySent)
                    lastBatchId=matlab.internal.editor.ExecutionStateTracker.getLastOutputBatchId(editorId,requestId);
                    updateTrackerCleanup=onCleanup(@()matlab.internal.editor.ExecutionStateTracker.notifyExecutionComplete(editorId,requestId));

                    message.publish([EvaluationOutputsService.REGIONS_EVAL_END,editorId],...
                    struct('didRunToCompletion',ev.DidRunToCompletion,...
                    'errorType',char(ev.ErrorType),...
                    'lastOutputBatchId',lastBatchId));

                    updateTrackerCleanup=[];%#ok<NASGU>
                    EODataStore.setEditorField(editorId,[EvaluationOutputsService.EVAL_END_MESSAGE_PREFIX,requestId],true);
                end
            catch e

                EvaluationOutputsService.sendException(e);
            end
        end

        function evaluationCleanup(editorId,requestId)
            import matlab.internal.editor.EODataStore
            import matlab.internal.editor.EvaluationOutputsService

            EODataStore.clearEditorField(editorId,[EvaluationOutputsService.EVAL_END_MESSAGE_PREFIX,requestId])
            EODataStore.clearEditorField(editorId,[EvaluationOutputsService.OUTPUT_STREAM_END_MESSAGE_PREFIX,requestId])
        end

        function cleanup(editorId)

            import matlab.internal.editor.EvaluationOutputsService
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
            matlab.internal.editor.ExecutionStateTracker.notifyEditorClose(editorId);
        end

        function clearOutputsCache(editorId)

            import matlab.internal.editor.*

            VariableManager.clearAll(editorId);
            FigureManager.clearFigures(editorId);
        end

        function sendException(exception)

            if~isempty(exception)

                exception.rethrow();
            end
        end

        function cleanupOnInterruption(editorId,requestId)
            matlab.internal.editor.FigureManager.disableCaptureFigures(editorId);


            matlab.internal.editor.FigureProxy.removeAnimatedOutput(editorId);
            matlab.internal.editor.OutputsManager.disableSuppression();
            matlab.internal.editor.OutputsManager.disableLiveEditorRunningFlag();
            matlab.internal.editor.EvaluationOutputsService.outputStreamingEnded(editorId,requestId);

            ev=matlab.internal.editor.events.EvaluationCompletionData([],false);
            matlab.internal.editor.EvaluationOutputsService.evaluationEnded([],ev,editorId,requestId);
            matlab.internal.editor.EvaluationOutputsService.evaluationCleanup(editorId,requestId);
        end

    end
end



