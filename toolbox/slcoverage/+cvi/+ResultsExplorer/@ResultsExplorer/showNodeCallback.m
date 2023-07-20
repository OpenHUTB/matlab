function showNodeCallback(topModelName,uuid)




    re=cvi.ResultsExplorer.ResultsExplorer.getInstance(topModelName,[]);
    node=re.findNode(uuid);
    re.show;
    cvi.ResultsExplorer.ResultsExplorer.activeNode(node,topModelName);
    node.parentTree.resultsExplorer.imme.selectTreeViewNode(node.interface);
    obj=node.parentTree.resultsExplorer;
    obj.ed.broadcastEvent('HierarchyChangedEvent',node.parentTree.root.interface);
end