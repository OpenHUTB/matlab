function openSearchFilter(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    app=slreq.app.MainManager.getInstance();
    editor=app.requirementsEditor;
    editor.showFilter();
end