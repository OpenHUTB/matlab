function cb_LaunchScheduleEditor(dlgHandle)




    model=dlgHandle.getSource.getBlock.getParent.Name;
    modelHandle=get_param(model,'Handle');
    editor=sltp.internal.ScheduleEditorManager.getEditor(modelHandle);
    editor.show();

end

