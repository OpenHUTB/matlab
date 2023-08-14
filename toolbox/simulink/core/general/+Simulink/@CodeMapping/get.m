function modelMapping=get(modelName,mappingType)




    if nargin<2
        [modelMapping,~]=Simulink.CodeMapping.getCurrentMapping(modelName);
    else
        if~any(strcmp(mappingType,{'AutosarTarget','AutosarTargetCPP',...
            'CoderDictionary','DistributedTarget','SimulinkCoderCTarget',...
            'CppModelMapping'}))
            assert(false,'The value of target must be AutosarTargetCPP or Adaptive Application or CoderDictionary or DistributedTarget or CppModelMapping.')
        end
        mappingManager=get_param(modelName,'MappingManager');
        modelMapping=mappingManager.getActiveMappingFor(mappingType);
    end
end
