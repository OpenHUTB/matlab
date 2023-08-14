function refreshCodeMapping(ssComponent,obj,propertyName)


    st=ssComponent.getStudio();
    modelH=st.App.getActiveEditor.blockDiagramHandle;
    mmgr=get_param(modelH,'MappingManager');
    mdlName=get_param(modelH,'Name');

    if any(strcmp(mmgr.getCurrentMapping(),{'AutosarTarget','AutosarTargetCPP'}))


        sync_stage=Simulink.output.Stage(message('RTW:autosar:syncStage').getString(),...
        'ModelName',mdlName,'UIMode',true);%#ok<NASGU>

        try
            autosar.api.syncModel(modelH);
        catch ME


            autosar.ui.utils.parseException(...
            ME,...
            autosar.ui.configuration.PackageString.MapRootName,...
            autosar.ui.configuration.PackageString.MappingLink,...
            [],[],[],[],[],modelH,'Error');
        end
    else
        try
            sync_stage=Simulink.output.Stage(DAStudio.message('coderdictionary:mapping:CodeProperties_CCodeSyncStage'),...
            'ModelName',mdlName,'UIMode',true);%#ok<NASGU>
            compiledModelCleanupObj=simulinkcoder.internal.util.CompiledModelUtils.forceCompiledModel(modelH);
            compiledModelCleanupObj.delete();
        catch ME
            coder.mapping.internal.parseException(...
            ME,...
            [],[],[],[],[],modelH,'Error');
        end
    end

