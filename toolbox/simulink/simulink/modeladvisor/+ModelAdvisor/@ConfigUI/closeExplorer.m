function closeExplorer






    am=Advisor.Manager.getInstance;
    mdladvObj=[];
    existingApplications=am.ApplicationObjMap.values;
    for i=1:length(existingApplications)
        currentMAObj=existingApplications{i}.getRootMAObj;
        if isa(currentMAObj.ConfigUIWindow,'DAStudio.Explorer')
            mdladvObj=currentMAObj;
        end
    end

    if isa(mdladvObj,'Simulink.ModelAdvisor')&&...
        isa(mdladvObj.ConfigUIWindow,'DAStudio.Explorer')

        userCancel=modeladvisorprivate('modeladvisorutil2','PromptConfigurationSaveDialogIfDirty',mdladvObj);
        if userCancel
            return;
        else
            mdladvObj.ConfigUIDirty=false;
        end





        mdladvObj.ConfigUIWindow.delete;


    end
