


function migrateCPPCS(modelName,activeCS)
    [modelMapping,mappingType]=Simulink.CodeMapping.getOrCreateCMapping(modelName);

    if~strcmp(mappingType,'CppModelMapping')
        return;
    end

    if isa(activeCS,'Simulink.ConfigSetRef')
        csCopy=activeCS;
    else
        csCopy=activeCS.copy();
        csCopy.detach();
    end

    Simulink.CodeMapping.setCppMappingClassConfigFromCS(modelMapping,csCopy,'ExternalIOMemberVisibility');
    Simulink.CodeMapping.setCppMappingClassConfigFromCS(modelMapping,csCopy,'ParameterMemberVisibility');
    Simulink.CodeMapping.setCppMappingClassConfigFromCS(modelMapping,csCopy,'InternalMemberVisibility');


    Simulink.CodeMapping.setCppMappingClassConfigFromCS(modelMapping,csCopy,'GenerateExternalIOAccessMethods');
    Simulink.CodeMapping.setCppMappingClassConfigFromCS(modelMapping,csCopy,'GenerateParameterAccessMethods');
    Simulink.CodeMapping.setCppMappingClassConfigFromCS(modelMapping,csCopy,'GenerateInternalMemberAccessMethods');
end
