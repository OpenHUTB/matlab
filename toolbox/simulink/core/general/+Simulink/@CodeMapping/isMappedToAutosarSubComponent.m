function[isMapped,modelMapping]=isMappedToAutosarSubComponent(modelName)




    modelMapping=[];
    mappingManager=get_param(modelName,'MappingManager');
    mapping=mappingManager.getActiveMappingFor('AutosarTarget');
    isMapped=isa(mapping,'Simulink.AutosarTarget.ModelMapping')&&mapping.IsSubComponent;
    if isMapped
        modelMapping=mapping;
    end
end
