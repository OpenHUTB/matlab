function paste(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    app=slreq.app.MainManager.getInstance();
    editor=app.requirementsEditor;
    slreq.app.CallbackHandler.pasteItem(editor.getCurrentSelection);
end