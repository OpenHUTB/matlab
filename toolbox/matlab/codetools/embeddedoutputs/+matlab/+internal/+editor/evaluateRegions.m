function evaluateRegions(editorId,requestId,regionList,fullText,shouldResetState,shouldUseTempFile,filePath,lastDocumentState,...
    regionStartHandler,sectionEndHandler,...
    outputStreamHandler,evaluationEndHandler,...
    outputStreamingEndHandler,isPrewarmExecution)

































    import matlab.internal.editor.*

    regionEvaluator=matlab.internal.language.RegionEvaluator();
    outputsManager=OutputsManager();



    cleanupObj.endCapture=onCleanup(@()cleanupOutputManager(outputsManager,editorId));
    cleanupObj.regionEvaluator=onCleanup(@()delete(regionEvaluator));

    outputsManager.initialize(regionEvaluator);


    if~isempty(regionStartHandler)
        regionStartLis=addlistener(regionEvaluator,'PRE_REGION',regionStartHandler);
        cleanupObj.deleteRSL=onCleanup(@(~,~)delete(regionStartLis));
    end
    if~isempty(sectionEndHandler)
        sectionEndLis=addlistener(regionEvaluator,'SECTION_END',sectionEndHandler);
        cleanupObj.deleteSEL=onCleanup(@(~,~)delete(sectionEndLis));
    end
    if~isempty(outputStreamHandler)
        outputsManager.addFlushOutputsHandler(outputStreamHandler);
    end
    if~isempty(outputStreamingEndHandler)
        outputsManager.addOutputStreamingEndedHandler(outputStreamingEndHandler);
    end
    if~isempty(evaluationEndHandler)
        evalEndLis=addlistener(regionEvaluator,'EVALUATION_ENDING',evaluationEndHandler);
        cleanupObj.deleteEvalEndLis=onCleanup(@(~,~)delete(evalEndLis));
    end




    EDITOR_LOCK_TAG='EDITOR_LOCK';
    cleanupObj.unlock=onCleanup(@()EODataStore.setEditorField(editorId,EDITOR_LOCK_TAG,false));
    EODataStore.setEditorField(editorId,EDITOR_LOCK_TAG,true);


    outputsManager.beginCapture(editorId,shouldResetState);


    lineToCallbackMap=EODataStore.getEditorField(editorId,'LINE_TO_CALLBACK_MAP');

    StackPruner.getInstance().setBase(dbstack("-completenames"));
    cleanupObj.clearPruningBase=onCleanup(@()StackPruner.getInstance().clear());

    regionEvaluator.evalRegions(regionList,editorId,requestId,fullText,filePath,lastDocumentState,shouldUseTempFile,lineToCallbackMap,isPrewarmExecution);
end

function cleanupOutputManager(outputManager,editorId)
    try
        outputManager.endCapture(editorId);
    catch me
        if~strcmp(me.identifier,'MATLAB:handle_graphics:exceptions:UserBreak')
            rethrow(me)
        end
    end
    delete(outputManager);
end