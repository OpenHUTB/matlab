

function setupDebugService(modelH,sldvData)









    model=Simulink.ID.getFullName(modelH);
    opts=sldvData.AnalysisInformation.Options;


    avData=get_param(modelH,'AutoVerifyData');
    if~isempty(avData)&&isfield(avData,'DebugService')&&...
        ~isempty(avData.DebugService)
        delete(avData.DebugService);
        avData.DebugService=[];
        set_param(modelH,'AutoVerifyData',avData);
    end

    if strcmp(opts.Mode,'PropertyProving')
        debugServiceObj=SldvDebugger.PP.DebugService(model,sldvData);
    elseif strcmp(opts.Mode,'DesignErrorDetection')
        debugServiceObj=SldvDebugger.DED.DebugService(model,sldvData);
    elseif strcmp(opts.Mode,'TestGeneration')
        debugServiceObj=SldvDebugger.TestGeneration.DebugService(model,sldvData);
    else
        return;
    end




    avData.DebugService=debugServiceObj;
    set_param(modelH,'AutoVerifyData',avData);
end
