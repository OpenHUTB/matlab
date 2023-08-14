function toggleDialog(~)




    editor=Simulink.typeeditor.app.Editor.getInstance;
    dialogComp=editor.getDialogComp;
    if dialogComp.isMinimized
        dialogComp.restore;
    else
        dialogComp.minimize;
    end
end