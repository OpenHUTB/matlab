function[isMapped,modelMapping]=isMappedToAutosarComponent(modelName)




    mappingManager=get_param(modelName,'MappingManager');
    modelMapping=mappingManager.getActiveMappingFor('AutosarTarget');

    isMapped=isa(modelMapping,'Simulink.AutosarTarget.ModelMapping');
end
