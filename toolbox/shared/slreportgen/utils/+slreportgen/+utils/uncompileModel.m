function uncompileModel(model)






















    if isempty(model)
        return;
    end

    modelH=slreportgen.utils.getModelHandle(model);

    status=get_param(modelH,'SimulationStatus');
    switch status
    case 'paused'
        uncompileUsingInternalAPI(modelH);
    case 'stopped'

    otherwise

        modelName=get_param(modelH,'Name');
        error(message(...
        'slreportgen:utils:error:cannotTerminateInState',...
        modelName,...
        status));
    end
end






function uncompileUsingInternalAPI(modelH)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok
    modelObj=get_param(modelH,'Object');
    modelObj.term();
end

