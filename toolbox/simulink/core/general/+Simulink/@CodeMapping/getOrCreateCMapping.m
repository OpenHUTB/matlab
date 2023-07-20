function[modelMapping,mappingType]=getOrCreateCMapping(modelName)




    [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);

    if~any(strcmp(mappingType,{'CppModelMapping','CoderDictionary','SimulinkCoderCTarget'}))
        modelMapping=[];
        mappingType=[];
        return;
    end



    if isempty(modelMapping)
        Simulink.CodeMapping.create(modelName,'init',mappingType);
        [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(modelName);
    end
end
