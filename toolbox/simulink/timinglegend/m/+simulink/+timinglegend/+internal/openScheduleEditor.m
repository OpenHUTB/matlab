function openScheduleEditor(modelHandleStr)
    modelHandle=str2num(modelHandleStr);
    editor=sltp.internal.ScheduleEditorManager.getEditor(modelHandle);
    editor.show();
end
