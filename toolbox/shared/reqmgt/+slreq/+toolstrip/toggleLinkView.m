function toggleLinkView(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    mgr=slreq.app.MainManager.getInstance();
    view=mgr.requirementsEditor;
    if cbinfo.EventData==1&&view.isReqViewActive
        view.switchView;
    end
end