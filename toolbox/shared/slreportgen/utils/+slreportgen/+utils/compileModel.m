function compileModel(model)






















    if isempty(model)
        return;
    end

    modelH=slreportgen.utils.getModelHandle(model);
    status=get_param(modelH,'SimulationStatus');
    switch status
    case 'stopped'
        compileUsingInternalAPI(modelH);

    case 'paused'


    otherwise
        modelName=get_param(modelH,'Name');

        error(message('slreportgen:utils:error:cannotCompileInState',modelName,status));
    end
end






function compileUsingInternalAPI(modelH)
    sfFeatureState=sf('feature','EML IncrementalCodegenForMatlabToolbox');
    restoreSFFeature=onCleanup(...
    @()sf('feature','EML IncrementalCodegenForMatlabToolbox',sfFeatureState));
    sf('feature','EML IncrementalCodegenForMatlabToolbox',1);

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok
    modelObj=get_param(modelH,'Object');
    modelObj.init('Command_line');
end