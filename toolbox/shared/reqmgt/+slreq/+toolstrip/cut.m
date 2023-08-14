function cut(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    app=slreq.app.MainManager.getInstance();
    editor=app.requirementsEditor;
    slreq.app.CallbackHandler.cutItem(editor.getCurrentSelection);
end