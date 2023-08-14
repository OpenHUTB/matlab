function toggleHierarchyView(cbinfo)

    viewMgr=slreq.app.MainManager.getInstance.viewManager;
    if~isempty(viewMgr)
        curView=viewMgr.getCurrentView();
        curView.toggleHierarchy();
    end

end