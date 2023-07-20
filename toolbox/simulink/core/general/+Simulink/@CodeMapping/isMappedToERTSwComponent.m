function[isMapped,modelMapping]=isMappedToERTSwComponent(modelName)




    mappingManager=get_param(modelName,'MappingManager');
    modelMapping=mappingManager.getActiveMappingFor('CoderDictionary');




    isMapped=isa(modelMapping,'Simulink.CoderDictionary.ModelMapping');
end
