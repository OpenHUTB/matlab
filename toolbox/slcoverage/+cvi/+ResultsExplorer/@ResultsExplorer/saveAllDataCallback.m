function saveAllDataCallback(topModelName)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    obj=node.parentTree.resultsExplorer;
    allData=obj.maps.uniqueIdMap.values;
    warnMsg=[];
    warnMsgTitle=[];
    for idx=1:numel(allData)
        d=allData{idx};
        [twarnMsg,twarnMsgTitle]=saveCvd(d);
        if~isempty(twarnMsg)
            warnMsgTitle=twarnMsgTitle;
            warnMsg=[warnMsg,' ',twarnMsg];%#ok<AGROW>
        end
    end
    if~isempty(warnMsg)
        warndlg(warnMsg,warnMsgTitle,'modal');
    end
    obj.ed.broadcastEvent('HierarchyChangedEvent',node.interface);
end