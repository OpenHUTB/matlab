classdef OutputsManager<handle


    properties
        EventPreprocessor=[];
        EventCollector=[];


        OutOfBandOutputEvents=[];


        BatchedOutputEvents={};


        CompletedRegionNumbers=[];

        FigureOutputReadyListener=event.listener.empty;


        StreamGovernor=[];

        StreamOutputsSignalListener=event.listener.empty;

        DebugHandler=[];
        DebugEventListeners=event.listener.empty;


        LastKnownLineNumber=-1;
        EditorId=[];

        IsActive=false;

        FlushOutputsHandler=[];
        OutputStreamingEndedHandler=[];

    end

    properties(Constant)
        COMMANDLINE_SUPPRESSION='SuppressCommandLineOutput';
        ALLOW_OUTPUT_CAPTURING='AllowOutputCapture';
        LIVE_EDITOR_RUNNING_FLAG='LiveEditorRunning';
    end

    methods

        function obj=OutputsManager()
        end

        function initialize(obj,regionEvaluator)
            import matlab.internal.editor.OutputsManager;
            import matlab.internal.editor.OutputEventPreprocessor;
            import matlab.internal.editor.StreamOutputsSignal;
            import matlab.internal.editor.FigureManager;
            import matlab.internal.editor.debug.DebugManager;



            obj.EventCollector=matlab.internal.language.EventsCollector();
            obj.EventPreprocessor=OutputEventPreprocessor(obj.EventCollector);
            obj.StreamGovernor=matlab.internal.language.StreamGovernor(@obj.streamOutputsCallback);

            addlistener(regionEvaluator,'PRE_REGION',@obj.preRegionCallback);
            addlistener(regionEvaluator,'POST_REGION',@obj.postRegionCallback);
            addlistener(regionEvaluator,'RUNTIME_ERROR_THROWN',@obj.handleRuntimeError);
            addlistener(regionEvaluator,'SYNTAX_ERROR_THROWN',@obj.handleSyntaxError);
            addlistener(regionEvaluator,'EVALUATION_ENDING',@obj.evalEndingCallback);

            figureManager=FigureManager.getInstance();
            obj.FigureOutputReadyListener=event.listener(figureManager,'FigureOutputReady',@obj.addFigureOutput);

            streamSignal=StreamOutputsSignal.getInstance();
            obj.StreamOutputsSignalListener(1)=event.listener(streamSignal,'ShouldStream',@(~,~)obj.possiblyStream);
            obj.StreamOutputsSignalListener(2)=event.listener(streamSignal,'ForceStream',@(~,~)obj.streamOutputsCallback);

            obj.DebugHandler=matlab.internal.language.DebugHandler;
            debugManager=DebugManager.getInstance();
            obj.DebugEventListeners(1)=event.listener(debugManager,'DBStop',@(~,~)OutputsManager.doDBStop);
            obj.DebugEventListeners(2)=event.listener(debugManager,'DBCont',@(~,~)OutputsManager.doDBCont);
        end

        function beginCapture(obj,editorId,shouldResetState)




            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.VariableManager
            import matlab.internal.editor.EODataStore

            figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>





            if shouldResetState
                FigureManager.closeAllEditorFigures(editorId);
                VariableManager.removeAllVariablesForEditor(editorId);
            else
                FigureManager.closeAllInterruptedEditorFigures(editorId);
            end


            OutputsManager.enableLiveEditorRunningFlag();
            FigureManager.enableCaptureFigures(editorId);
            OutputsManager.enableCapture();
            OutputsManager.enableSuppression();


            obj.EditorId=editorId;
            EODataStore.setRootField('RunningEditor',editorId);

            builtin('_setTextOutputListeners','push');
            builtin('_StructuredFiguresResetAll');

            obj.IsActive=true;

        end

        function endCapture(obj,editorId)
            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.FigureManager

            obj.IsActive=false;

            builtin('_setTextOutputListeners','pop');


            FigureManager.disableCaptureFigures(editorId);
            FigureManager.cleanupAfterEval(editorId);
            OutputsManager.disableSuppression();
            OutputsManager.disableLiveEditorRunningFlag();
        end

        function preRegionCallback(obj,~,eventData)
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.VariableManager

            obj.LastKnownLineNumber=eventData.RegionLineNumber;

            FigureManager.setCurrentRegion(eventData.editorId,eventData.RegionNumber);
        end

        function postRegionCallback(obj,~,eventData)
            import matlab.internal.editor.FigureManager

            warningSuppressor=matlab.internal.editor.LastWarningGuard;%#ok<NASGU>

            figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>

            regionNumber=eventData.RegionNumber;
            firstLineNumberOfRegion=eventData.RegionLineNumber;
            editorId=eventData.editorId;
            isFigureStreamPoint=eventData.isFigureStreamPoint;


            obj.collectEvents(editorId,firstLineNumberOfRegion);

            if isFigureStreamPoint
                FigureManager.snapshotAllFigures(editorId);
            end

            obj.CompletedRegionNumbers=[obj.CompletedRegionNumbers,regionNumber];

            obj.streamOutputsCallback();

        end

        function evalEndingCallback(obj,~,~)

            obj.streamOutputsCallback();



            obj.IsActive=false;

            obj.notifyOutputStreamingEnded();
        end

        function addFigureOutput(obj,~,eventData)
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.OutputPackagerUtilities
            import matlab.internal.editor.OutputsManager



            if~strcmp(eventData.EditorId,obj.EditorId)
                return;
            end

            figureStruct=eventData.FigureStruct;








            if isfield(figureStruct,'renderWarning')&&~isempty(figureStruct.renderWarning)
                obj.addWarningEventToSpecifiedLine(figureStruct.renderWarning,figureStruct.lineNumbers(end));
            end


            figureData=OutputsManager.makeMockEvalStruct(OutputPackagerUtilities.FIGURE_TYPE,figureStruct,[]);
            obj.OutOfBandOutputEvents=[obj.OutOfBandOutputEvents;figureData];

            obj.possiblyStream();
        end

        function possiblyStream(obj)
            warningSuppressor=matlab.internal.editor.LastWarningGuard;%#ok<NASGU>
            obj.flushAllOutputEvents();
            obj.StreamGovernor.possibleStreamPoint();
        end

        function flushAllOutputEvents(obj)
            firstLineNumberOfRegion=obj.LastKnownLineNumber;

            obj.collectEvents(obj.EditorId,firstLineNumberOfRegion);


            if~isempty(obj.OutOfBandOutputEvents)&&firstLineNumberOfRegion~=-1
                obj.insertOutOfBandOutputEventsIntoBatchedOutputEvents(firstLineNumberOfRegion);
            end
        end

        function streamOutputsCallback(obj)









            import matlab.internal.editor.events.BatchedOutputEventsEventData

            if~obj.IsActive
                return;
            end

            warningSuppressor=matlab.internal.editor.LastWarningGuard;%#ok<NASGU>
            figureEventDisabler=matlab.internal.editor.FigureEventDisabler;%#ok<NASGU>

            matlab.internal.editor.FigureManager.processPendingDrawnow();

            obj.flushAllOutputEvents();

            if~isempty(obj.BatchedOutputEvents)||~isempty(obj.CompletedRegionNumbers)

                data=BatchedOutputEventsEventData(obj.BatchedOutputEvents,obj.CompletedRegionNumbers);


                obj.BatchedOutputEvents={};
                obj.CompletedRegionNumbers=[];

                obj.notifyFlushOutputs(data);
            end
        end

        function insertOutOfBandOutputEventsIntoBatchedOutputEvents(obj,firstLineNumberOfRegion)











            if~isempty(obj.OutOfBandOutputEvents)
                obj.addOutputEventsToBatch(obj.OutOfBandOutputEvents,firstLineNumberOfRegion);
                obj.OutOfBandOutputEvents=[];
            end
        end

        function handleSyntaxError(obj,~,eventData)








            import matlab.internal.editor.EvaluationOutputsService
            import matlab.internal.editor.ErrorType


            obj.addErrorEventToOutOfBandOutputEvents(eventData.Exception,eventData.FullFilePath,ErrorType.Syntax);

            obj.insertOutOfBandOutputEventsIntoBatchedOutputEvents(eventData.RegionLineNumber);
        end

        function handleRuntimeError(obj,~,eventData)



            import matlab.internal.editor.ErrorType

            obj.addErrorEventToOutOfBandOutputEvents(eventData.Exception,eventData.FullFilePath,ErrorType.Runtime);
        end

        function addErrorEventToOutOfBandOutputEvents(obj,aException,filePath,errorType)
            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.OutputPackagerUtilities



            payload=struct('exception',aException,'errorType',errorType,'fullFilePath',filePath);
            errorEvent=OutputsManager.makeMockEvalStruct(OutputPackagerUtilities.STRUCT_EVAL_ERROR_TYPE,payload,aException.stack);


            obj.OutOfBandOutputEvents=[obj.OutOfBandOutputEvents;errorEvent];
        end

        function addWarningEventToSpecifiedLine(obj,aWarning,lineNumber)
            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.OutputPackagerUtilities






            payload=struct('message',aWarning,'wasDisabled',false);
            warnEvent=OutputsManager.makeMockEvalStruct(OutputPackagerUtilities.STRUCT_EVAL_WARNING_TYPE,payload,[]);





            obj.addOutputEventsToBatch(warnEvent,lineNumber);
        end


        function addFlushOutputsHandler(obj,handler)
            obj.FlushOutputsHandler=handler;
        end

        function addOutputStreamingEndedHandler(obj,handler)
            obj.OutputStreamingEndedHandler=handler;
        end

        function notifyFlushOutputs(obj,data)
            if~isempty(obj.FlushOutputsHandler)
                obj.FlushOutputsHandler([],data);
            end
        end

        function notifyOutputStreamingEnded(obj)
            if~isempty(obj.OutputStreamingEndedHandler)
                obj.OutputStreamingEndedHandler([],[]);
            end
        end

        function delete(obj)
            import matlab.internal.editor.OutputsManager

            obj.reset();
            obj.StreamOutputsSignalListener=[];
            obj.FigureOutputReadyListener=[];
            obj.DebugHandler=[];
            obj.DebugEventListeners=[];
            obj.FlushOutputsHandler=[];
            obj.OutputStreamingEndedHandler=[];

            OutputsManager.disableSuppression()
            delete(obj.EventCollector);
            delete(obj.EventPreprocessor);
            delete(obj.StreamGovernor);
        end
    end

    methods(Access=private)

        function collectEvents(obj,editorId,firstLineNumberOfRegion)


            processedEvents=obj.EventPreprocessor.flushEvents(editorId);
            if~isempty(processedEvents)
                obj.addOutputEventsToBatch(processedEvents,firstLineNumberOfRegion);
            end
        end

        function addOutputEventsToBatch(obj,evalStructs,firstLineNumberOfRegion)
            numberOfStructs=numel(evalStructs);
            wrappedOutputs=cell(numberOfStructs,1);
            for i=1:numberOfStructs

                wrappedOutputs{i}=struct('regionLineNumber',firstLineNumberOfRegion,...
                'evalStruct',evalStructs(i));
            end
            obj.BatchedOutputEvents=[obj.BatchedOutputEvents;wrappedOutputs];
        end

        function reset(obj)
            obj.OutOfBandOutputEvents=[];
            obj.BatchedOutputEvents={};
            if~isempty(obj.EventPreprocessor)
                obj.EventPreprocessor.clearEvents();
            end
        end
    end

    methods(Static,Hidden)

        function enableCapture()
            import matlab.internal.editor.OutputsManager
            feature(OutputsManager.ALLOW_OUTPUT_CAPTURING,true);
        end

        function disableCapture()
            import matlab.internal.editor.OutputsManager
            feature(OutputsManager.ALLOW_OUTPUT_CAPTURING,false);
        end

        function enableSuppression()
            import matlab.internal.editor.OutputsManager
            feature(OutputsManager.COMMANDLINE_SUPPRESSION,true);
        end

        function disableSuppression()
            import matlab.internal.editor.OutputsManager
            feature(OutputsManager.COMMANDLINE_SUPPRESSION,false);
        end

        function enableLiveEditorRunningFlag()
            import matlab.internal.editor.OutputsManager
            feature(OutputsManager.LIVE_EDITOR_RUNNING_FLAG,true);
        end

        function disableLiveEditorRunningFlag()
            import matlab.internal.editor.OutputsManager
            feature(OutputsManager.LIVE_EDITOR_RUNNING_FLAG,false);
        end

        function evalStruct=makeMockEvalStruct(type,payload,stack)
            evalStruct=struct('type',type,'payload',payload,'stack',stack);
        end

        function cleanup()
            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.FigureEventDisabler
            OutputsManager.disableLiveEditorRunningFlag();
            OutputsManager.disableSuppression();
            FigureEventDisabler.enable();
        end

        function doDBStop()
            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.FigureEventDisabler
            import matlab.internal.editor.StreamOutputsSignal
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.EODataStore

            warningSuppressor=matlab.internal.editor.LastWarningGuard;%#ok<NASGU>

            StreamOutputsSignal.stream();

            editorId=EODataStore.getRootField('RunningEditor');

            FigureManager.snapshotPendingFigures(editorId);
            StreamOutputsSignal.forceStream();

            FigureManager.disableCaptureFigures(editorId);

            FigureEventDisabler.disable();
            OutputsManager.disableSuppression();
            OutputsManager.disableCapture();

            OutputsManager.disableLiveEditorRunningFlag();
        end

        function doDBCont()
            import matlab.internal.editor.OutputsManager
            import matlab.internal.editor.FigureEventDisabler
            import matlab.internal.editor.FigureManager
            import matlab.internal.editor.EODataStore

            warningSuppressor=matlab.internal.editor.LastWarningGuard;%#ok<NASGU>

            builtin('_StructuredFiguresResetAll');

            editorId=EODataStore.getRootField('RunningEditor');


            FigureManager.enableCaptureFigures(editorId);

            OutputsManager.enableSuppression();
            OutputsManager.enableCapture();
            FigureEventDisabler.enable();


            OutputsManager.enableLiveEditorRunningFlag();
        end
    end
end
