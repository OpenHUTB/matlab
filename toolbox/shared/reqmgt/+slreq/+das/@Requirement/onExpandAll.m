function onExpandAll()

    if~slreq.app.MainManager.hasEditor()
        return;
    end
    mgr=slreq.app.MainManager.getInstance;
    currentView=mgr.getCurrentView;
    if~isempty(currentView)
        currentObj=currentView.getCurrentSelection();
        if~isempty(currentObj)
            currentView.expandAll(currentObj);
        end
    end
end