function[isMapped,modelMapping]=isMappedToCppERTSwComponent(modelName)




    mappingManager=get_param(modelName,'MappingManager');
    modelMapping=mappingManager.getActiveMappingFor('CppModelMapping');
    isMapped=isa(modelMapping,'Simulink.CppModelMapping.ModelMapping');
end
