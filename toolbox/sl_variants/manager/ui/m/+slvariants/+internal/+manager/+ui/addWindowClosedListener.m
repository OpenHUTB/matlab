function addWindowClosedListener(bdHandle)








    studioContainerObj=slvariants.internal.manager.core.getStudioContainer(bdHandle);

    studioContainerObj.onCloseRequested=@handleVMgrWindowCloseRequest;

    function closeWindow=handleVMgrWindowCloseRequest(~,~)
        closeWindow=true;

        modelName=getfullname(bdHandle);
        dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
        configSchema=dlg.getSource;

        if~configSchema.IsSourceObjDirtyFlag

            vMgrCleanup();
            return;
        end

        vcdoUIName=configSchema.ConfigObjVarName;
        vcdoWS=configSchema.ConfigCatalogCacheWrapper.ConfigWorkspace;

        if~isempty(vcdoUIName)
            questMsg=DAStudio.message(...
            'Simulink:VariantManagerUI:VariantManagerPromptUnexportedVcdochanges',...
            vcdoUIName,vcdoWS);
            yesStr=DAStudio.message('MATLAB:uistring:popupdialogs:Yes');
            noStr=DAStudio.message('MATLAB:uistring:popupdialogs:No');
            cancelStr=DAStudio.message('MATLAB:uistring:popupdialogs:Cancel');

            sel=questdlg(questMsg,modelName,yesStr,noStr,cancelStr,cancelStr);

            switch sel
            case yesStr
                configSchema.ConfigCatalogCacheWrapper.applyVariantConfigurationCatalogCache(configSchema.ConfigObjVarName);
                vMgrCleanup();
            case noStr
                vMgrCleanup();
            case cancelStr
                closeWindow=false;
            end
        else
            questMsg=DAStudio.message(...
            'Simulink:VariantManagerUI:VariantManagerPromptUnexportedChangesEmptyInsync');
            yesStr=DAStudio.message('MATLAB:uistring:popupdialogs:Yes');
            cancelStr=DAStudio.message('MATLAB:uistring:popupdialogs:Cancel');

            sel=questdlg(questMsg,modelName,yesStr,cancelStr,cancelStr);

            switch sel
            case yesStr
                vMgrCleanup();
            case cancelStr
                closeWindow=false;
            end
        end

        function vMgrCleanup()
            slvariants.internal.manager.ui.utils.toolstripTabChangeCB('variantManagerTab',bdHandle);


            configSchema.stopAndDeleteTimer();

            slvariants.internal.manager.core.onWindowClose(bdHandle);
        end
    end

end


