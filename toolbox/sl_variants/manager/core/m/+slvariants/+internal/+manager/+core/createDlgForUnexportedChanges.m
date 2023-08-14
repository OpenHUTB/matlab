function tabChangeAllowed=createDlgForUnexportedChanges(modelHandle,configSchema,toolStrip)





    tabChangeAllowed=true;

    if~configSchema.IsSourceObjDirtyFlag
        return;
    end

    if isempty(configSchema.ConfigObjVarName)



        dp=DAStudio.DialogProvider;
        errorMessage=DAStudio.message('Simulink:VariantManagerUI:MessageConfigdatacantexportwithemptynameError');
        dp.errordlg(errorMessage,getString(message('MATLAB:uistring:popupdialogs:ErrorDialogTitle')),true);



        pause(1);
        toolStrip.ActiveTab='variantManagerTab';
        tabChangeAllowed=false;
        return;
    end


    slvariants.internal.manager.core.disableUI(modelHandle);
    cleanupObj=onCleanup(@()slvariants.internal.manager.core.enableUI(modelHandle));
    yes=message('MATLAB:uistring:popupdialogs:Yes').getString();
    no=message('MATLAB:uistring:popupdialogs:No').getString();
    questMsg=DAStudio.message('Simulink:VariantManagerUI:VariantManagerPromptUnappliedVcdochanges',...
    configSchema.ConfigObjVarName);
    selection=questdlg(questMsg,configSchema.BDName,yes,no,no);
    if strcmp(selection,yes)



        slvariants.internal.manager.ui.config.ConfigurationsDialogSchema.applyVariantConfigurations(configSchema);
    else




        toolStrip.ActiveTab='variantManagerTab';
        tabChangeAllowed=false;
    end
end


