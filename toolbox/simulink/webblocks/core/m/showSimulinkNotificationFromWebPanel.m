function showSimulinkNotificationFromWebPanel(editorWebId,notificationTag,notification,needsModelName)
    editor=SLM3I.SLDomain.getEditorForWebId(editorWebId);
    if(isempty(editor))
        return
    end
    if(needsModelName)
        modelName=get_param(editor.getStudio().App.blockDiagramHandle,'Name');
        notification=strrep(notification,'{{MODEL_NAME}}',['''',modelName,'''']);
    end
    editor.deliverInfoNotification(notificationTag,notification);
end
