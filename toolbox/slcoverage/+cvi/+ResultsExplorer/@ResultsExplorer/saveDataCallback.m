function saveDataCallback(topModelName)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    obj=node.parentTree.resultsExplorer;
    [warnMsg,warnMsgTitle]=saveCvd(node.data);
    if~isempty(warnMsg)
        warndlg(warnMsg,warnMsgTitle,'modal');
    end
    obj.ed.broadcastEvent('HierarchyChangedEvent',node.interface);
end