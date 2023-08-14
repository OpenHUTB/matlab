function importFromFile(modelName,diagInterceptor,diagProcessor,migDiagStage)




    dlg=slvariants.internal.manager.ui.config.getConfigurationsDialog(modelName);
    configSchema=dlg.getSource;

    import slvariants.internal.manager.ui.config.*
    varConfigDataName=configSchema.ConfigObjVarName;

    if configSchema.IsSourceObjDirtyFlag&&~isempty(varConfigDataName)
        yes=message('MATLAB:uistring:popupdialogs:Yes').getString();
        no=message('MATLAB:uistring:popupdialogs:No').getString();
        questMsg=DAStudio.message('Simulink:VariantManagerUI:VariantManagerPromptUnexportedVcdochanges',...
        configSchema.ConfigObjVarName,configSchema.ConfigCatalogCacheWrapper.ConfigWorkspace);
        selection=questdlg(questMsg,configSchema.BDName,yes,no,no);
        switch selection
        case yes
            configSchema.ConfigCatalogCacheWrapper.applyVariantConfigurationCatalogCache(configSchema.ConfigObjVarName);
        case no
        end
    end

    [fileName,pathName]=importDialog(configSchema.BDName);
    if~ischar(fileName)

        return;
    end
    fullFileName=fullfile(pathName,fileName);
    [~,~,ext]=fileparts(fileName);
    if strcmp(ext,'.m')
        [varConfigObjectNames,varConfigObjects]=importFromMFile(fullFileName);
    else
        [varConfigObjectNames,varConfigObjects]=importFromMatFile(fullFileName);
    end

    if isempty(varConfigObjectNames)
        msg=message('Simulink:VariantManagerUI:ImportVCDOMissingDefinitions',fullFileName);
        exception=MException(msg);
        throw(exception);
    end

    bdHandle=configSchema.BDHandle;

    if length(varConfigObjectNames)==1&&strcmp(varConfigDataName,varConfigObjectNames)
        configSchema.ConfigCatalogCacheWrapper.setVariantConfigurationCatalog(varConfigObjects{1});
        sourceCacheObj=configSchema.ConfigCatalogCacheWrapper;
        isStandalone=false;
        mdlName=configSchema.BDName;

        newConfigSrc=ConfigurationsDialogSchema(sourceCacheObj,isStandalone,bdHandle);
        dlg.setSource(newConfigSrc);

        newConstrSrc=ConstraintsDialogSchema(sourceCacheObj,isStandalone,bdHandle);
        constrDlg=slvariants.internal.manager.ui.config.getConstraintsDialog(mdlName);
        constrDlg.setSource(newConstrSrc);

        importFromFileMsg=MException(message('Simulink:VariantManagerUI:VariantManagerImportSuccessfulMessage',varConfigObjectNames{1},fullFileName));
        sldiagviewer.reportInfo(importFromFileMsg);

        return;
    end


    slvariants.internal.manager.core.disableUI(bdHandle);

    varConfigObjectSelectorDlg=VariantConfigurationsObjectSelectorDialog(...
    configSchema,varConfigObjectNames,varConfigObjects,dlg);
    dialogHandle=DAStudio.Dialog(varConfigObjectSelectorDlg);


    varConfigObjectSelectorDlg.ObjectDestructionListener=handle.listener(dialogHandle,...
    'ObjectBeingDestroyed',@(s,e)varConfigObjectSelectorDlgOnDestroy());

    function varConfigObjectSelectorDlgOnDestroy()
        slvariants.internal.manager.core.enableUI(bdHandle);
        if isempty(varConfigObjectSelectorDlg.SelectedConfigObjectIdx)

            return;
        end
        selectedVCDOName=varConfigObjectNames{varConfigObjectSelectorDlg.SelectedConfigObjectIdx};

        importFromFileMsg=MException(message('Simulink:VariantManagerUI:VariantManagerImportSuccessfulMessage',...
        selectedVCDOName,fullFileName));
        sldiagviewer.reportInfo(importFromFileMsg);
        diagCleanupObj=onCleanup(@()cleanupFcn());

        function cleanupFcn()
            clear diagInterceptor;
            clear diagProcessor;
        end
    end
end


function[fileName,pathName]=importDialog(modelName)
    filter={...
    '*.m',DAStudio.message('MATLAB:uistring:uiopen:MATLABFiles');...
    '*.mat',DAStudio.message('MATLAB:uistring:uiopen:MATfiles');...
    };


    titlePrefix=[modelName,': '];
    title=[titlePrefix,DAStudio.message('Simulink:VariantManagerUI:VariantManagerImportFilechooserTitle')];


    bdHandle=get_param(modelName,'Handle');
    slvariants.internal.manager.core.disableUI(bdHandle);
    diagCleanUpObj=onCleanup(@()uiCleanUpFcn(bdHandle));

    [fileName,pathName]=uigetfile(filter,title);
    if ischar(fileName)&&~isempty(fileName)&&ischar(pathName)

        [~,~,ext]=fileparts(fileName);


        Simulink.variant.utils.assert(ismember(ext,{'.mat','.m'}));
    end

    function uiCleanUpFcn(modelHandle)
        if slvariants.internal.manager.core.hasOpenVM(modelHandle)
            slvariants.internal.manager.core.enableUI(modelHandle);
        end
    end
end



