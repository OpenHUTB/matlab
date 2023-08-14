function status=isModelOpenForInspect(modelH)





    status=false;
    avDataHandle=get_param(modelH,'AutoVerifyData');
    if isfield(avDataHandle,'DebugService')&&~isempty(avDataHandle.DebugService)
        obj=avDataHandle.DebugService;
        status=SldvDebugger.DebugService.isGeneratedForTestGeneration(obj.sldvData)&&obj.getIsDebugSessionActive;
    end
end
