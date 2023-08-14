function confirmSaveOnModelCloseRequest(modelHandle,sessionDataModel)







    designSession=sessionDataModel.topLevelElements;
    if designSession.IsDirty
        choice=simulink.multisim.internal.confirmSaveBeforeClose(modelHandle);
        switch choice
        case "yes"
            savedFileName=simulink.multisim.internal.utils.Session.saveFile(sessionDataModel,designSession,modelHandle);
            if isempty(savedFileName)
                error("Simulink:Commands:CancelCloseModel","Cancel model close");
            end
        case ""
            error("Simulink:Commands:CancelCloseModel","Cancel model close");
        end
    end
end