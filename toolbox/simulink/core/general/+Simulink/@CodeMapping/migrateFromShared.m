



function migrateFromShared(modelName,bMigrateSharedMapping)

    if nargin==1

        bMigrateSharedMapping=true;
    end

    [modelMapping,mappingType]=Simulink.CodeMapping.getOrCreateCMapping(modelName);
    if~strcmp(mappingType,'CoderDictionary')
        return;
    end

    wState=[warning;warning('query','RTW:configSet:migratedToCoderDictionary')];
    warning('off','RTW:configSet:migratedToCoderDictionary');
    wCleanup=onCleanup(@()warning(wState));

    mdlH=get_param(modelName,'Handle');
    activeCS=getActiveConfigSet(modelName);
    memSecPkg=get_param(activeCS,'MemSecPackage');

    ddName=get_param(mdlH,'DataDictionary');
    assert(~isempty(ddName),'DataDictionary is not present for the model');


    swct=coder.internal.CoderDataStaticAPI.getSWCT(ddName);
    if bMigrateSharedMapping
        Simulink.CodeMapping.createSharedUtilsMappingAndDataIfNecessary(activeCS,ddName,true,swct);
    end

    if~isequal(memSecPkg,'--- None ---')

        modelMapping.DefaultsMapping.set('Constants','MemorySection','');
        modelMapping.DefaultsMapping.set('Inports','MemorySection','');
        modelMapping.DefaultsMapping.set('Outports','MemorySection','');
        modelMapping.DefaultsMapping.set('LocalParameters','MemorySection','');
        modelMapping.DefaultsMapping.set('GlobalParameters','MemorySection','');
        modelMapping.DefaultsMapping.set('InternalData','MemorySection','');


        modelMapping.DefaultsMapping.set('InitializeTerminate','MemorySection','');
        modelMapping.DefaultsMapping.set('Execution','MemorySection','');
        modelMapping.DefaultsMapping.set('SharedUtility','MemorySection','');


        if bMigrateSharedMapping
            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecDataIO','Inports');
            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecDataIO','Outports');
            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecDataConstants','Constants');
            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecDataParameters','LocalParameters');
            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecDataParameters','GlobalParameters');
            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecDataInternal','InternalData');

            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecFuncInitTerm','InitializeTerminate');
            Simulink.CodeMapping.setSharedMappingMSFromCS(mdlH,activeCS,'MemSecFuncExecute','Execution');
        end
    end

end
