function[isMapped,modelMapping]=isMappedToAdaptiveApplication(modelName)




    modelMapping=[];
    mappingManager=get_param(modelName,'MappingManager');
    mapping=mappingManager.getActiveMappingFor('AutosarTargetCPP');
    isMapped=isa(mapping,'Simulink.AutosarTarget.AdaptiveModelMapping');
    if isMapped
        modelMapping=mapping;
    end
end
