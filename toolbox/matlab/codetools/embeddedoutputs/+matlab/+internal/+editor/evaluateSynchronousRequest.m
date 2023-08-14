function[output,cleanupObj]=evaluateSynchronousRequest(request)
    import matlab.internal.editor.SynchronousEvaluationOutputsService;


    [rawOutputs,cleanupObj]=SynchronousEvaluationOutputsService.evaluateSynchronously('editorId',request.requestId,request.regionArray,request.fullText,request.fullFilePath);


    output=jsonencode(rawOutputs);
end

