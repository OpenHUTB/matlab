function validateAll(model)




    import coder.mapping.internal.*;
    [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
    if isempty(modelMapping)
        return;
    end

    if isempty(modelMapping.SimulinkFunctionCallerMappings)
        return;
    end
    for i=1:length(modelMapping.SimulinkFunctionCallerMappings)
        currentMapping=modelMapping.SimulinkFunctionCallerMappings(i);
        if isempty(currentMapping)||isempty(currentMapping.SimulinkFunctionName)
            continue;
        end
        SimulinkFunctionMapping.validate(model,currentMapping.SimulinkFunctionName);
    end

    if strcmpi(mappingType,'CoderDictionary')
        SimulinkFunctionMapping.compileTimeChecks(...
        model,...
        @()Simulink.CoderDictionary.checkMappingsToStateflowFcns(get_param(model,'handle')),...
        @()Simulink.CoderDictionary.checkModelRefFPC(get_param(model,'handle')));
    else
        SimulinkFunctionMapping.compileTimeChecks(...
        model,...
        @()Simulink.CppModelMapping.checkMappingsToStateflowFcns(get_param(model,'handle')),...
        @()Simulink.CppModelMapping.checkModelRefFPC(get_param(model,'handle')));
    end
end
