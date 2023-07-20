function closeNotificationBar(modelName)


    editor=learning.simulink.getEditorFromModel(modelName);
    editor.closeNotificationByMsgID(editor.getActiveNotification);
end

