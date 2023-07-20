





function displayBannerMessage(obj)

    msgId='Sldv:DebugUsingSlicer:BannerMessageOnSetupComplete';


    setupMessage=getString(message('Sldv:DebugUsingSlicer:SetupCompleteSimpleMessage'));
    setupMessageExtraction=getString(message('Sldv:DebugUsingSlicer:SetupCompleteExtractionWorkflowMessage',...
    obj.model));

    simButtonEnableMessage=obj.getSimButtonEnableMessage();
    simButtonDisableMessage=getString(message('Sldv:DebugUsingSlicer:SimulationButtonDisabledMessage'));


    fastRestartMessage=getString(message('Sldv:DebugUsingSlicer:FastRestartNotSupported',...
    obj.model));

    space=' ';


    if obj.isExtractionWorkflow
        if obj.isFastRestartSupported
            msgstr=[setupMessageExtraction,space,simButtonEnableMessage];
        else
            msgstr=[setupMessageExtraction,space,fastRestartMessage,space,simButtonDisableMessage];
        end

    else
        if obj.isFastRestartSupported
            msgstr=[setupMessage,space,simButtonEnableMessage];
        else
            msgstr=[setupMessage,space,fastRestartMessage,space,simButtonDisableMessage];
        end
    end

    obj.DebugCtx.showNotificationInActiveEditor(msgId,msgstr);
end
