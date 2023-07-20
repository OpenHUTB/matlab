function copy(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    app=slreq.app.MainManager.getInstance();
    editor=app.requirementsEditor;
    slreq.app.CallbackHandler.copyItem(editor.getCurrentSelection);
end