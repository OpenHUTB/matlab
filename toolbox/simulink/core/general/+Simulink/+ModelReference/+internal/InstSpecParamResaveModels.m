function action_performed=InstSpecParamResaveModels(modelTobeSaved)





    refModelsToBeSaved=find_mdlrefs(modelTobeSaved,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
    for ii=1:numel(refModelsToBeSaved)
        InstSpecParamResaveModelsHelper(refModelsToBeSaved{ii});
    end
    action_performed=true;
end

function action_performed=InstSpecParamResaveModelsHelper(modelTobeSaved)
    load_system(modelTobeSaved);
    orgDirtyStatus=get_param(modelTobeSaved,'Dirty');
    try
        set_param(modelTobeSaved,'Dirty','on');
        save_system(modelTobeSaved);
        DAStudio.message('Simulink:modelReference:InstSpecParamMismatchResavingModel',modelTobeSaved);
        action_performed=true;
    catch err
        set_param(modelTobeSaved,'Dirty',orgDirtyStatus);
        close_system(modelTobeSaved,0);
        throw(err);
    end

end


