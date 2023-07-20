function newgui




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
    if isa(mdladvObj,'Simulink.ModelAdvisor')

        userCancel=modeladvisorprivate('modeladvisorutil2','PromptConfigurationSaveDialogIfDirty',mdladvObj);
        if userCancel
            return
        end

        mdladvObj.ConfigUIRoot={};
        mdladvObj.ConfigFilePath='';
        Simulink.ModelAdvisor.openConfigUI;
    end
