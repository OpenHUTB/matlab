function onCollapseAll()

    if~slreq.app.MainManager.hasEditor()
        return;
    end
    mgr=slreq.app.MainManager.getInstance;
    currentView=mgr.getCurrentView;
    currentObj=mgr.getCurrentViewSelections;
    if~isempty(currentObj)
        currentView.collapseAll(currentObj);
    end
end