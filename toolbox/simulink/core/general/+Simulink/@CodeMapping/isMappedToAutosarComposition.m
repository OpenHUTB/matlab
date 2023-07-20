function[isMapped,modelMapping]=isMappedToAutosarComposition(modelName)




    mappingManager=get_param(modelName,'MappingManager');

    modelMapping=mappingManager.getActiveMappingFor('AutosarComposition');
    isMapped=isa(modelMapping,'Simulink.AutosarTarget.CompositionModelMapping');
end
