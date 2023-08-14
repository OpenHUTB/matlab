function[isMapped,modelMapping]=isMappedToGRTSwComponent(modelName)




    mappingManager=get_param(modelName,'MappingManager');
    modelMapping=mappingManager.getActiveMappingFor('SimulinkCoderCTarget');
    isMapped=isa(modelMapping,'Simulink.CoderDictionary.ModelMappingSLC');
end
