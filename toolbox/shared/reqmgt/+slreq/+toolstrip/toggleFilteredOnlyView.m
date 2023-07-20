function toggleFilteredOnlyView(cbinfo)
    viewMgr=slreq.app.MainManager.getInstance.viewManager;
    if~isempty(viewMgr)
        curView=viewMgr.getCurrentView();
        curView.toggleFiltered();
    end
end