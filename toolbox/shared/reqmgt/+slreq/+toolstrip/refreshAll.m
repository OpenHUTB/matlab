function refreshAll(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    view=slreq.app.MainManager.getInstance.requirementsEditor;
    if~isempty(view)
        view.refreshAll();
    end
end