function deleteCallback(topModelName,permanently)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    obj=node.parentTree.resultsExplorer;
    obj.deleteTreeNode(node,permanently);
    obj.refreshTreeView;
end