function migrate(modelName)







    [modelMapping,mappingType]=Simulink.CodeMapping.getOrCreateCMapping(modelName);
    if~strcmp(mappingType,'CoderDictionary')
        return;
    end
    activeCS=getActiveConfigSet(modelName);



    Simulink.CodeMapping.createSharedUtilsMappingAndDataIfNecessary(activeCS,get_param(modelName,'Handle'),false,modelMapping);

    memSecPkg=get_param(activeCS,'MemSecPackage');
    if~isequal(memSecPkg,'--- None ---')
        wState=[warning;warning('query','RTW:configSet:migratedToCoderDictionary')];
        warning('off','RTW:configSet:migratedToCoderDictionary');
        wCleanup=onCleanup(@()warning(wState));

        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecDataIO','Inports');
        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecDataIO','Outports');
        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecDataConstants','Constants');
        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecDataParameters','LocalParameters');
        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecDataParameters','GlobalParameters');
        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecDataInternal','InternalData');

        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecFuncInitTerm','InitializeTerminate');
        Simulink.CodeMapping.setModelMappingMSFromCS(modelMapping,activeCS,'MemSecFuncExecute','Execution');

    end
end
