function clearCallback(topModelName)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    if~isempty(node)&&~isempty(node.children)
        node.parentTree.removeTree(node);
        node.parentTree.resultsExplorer.refreshTreeView;
    end
end