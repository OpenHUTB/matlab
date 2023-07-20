function gotoCallback(topModelName,isDst)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    if~isempty(node)

        if isDst
            in=node.data.dstNode;
        else
            in=node.srcNode;
        end
        node.parentTree.resultsExplorer.imme.selectTreeViewNode(in.interface);
        obj=node.parentTree.resultsExplorer;
        obj.ed.broadcastEvent('HierarchyChangedEvent',node.parentTree.root.interface);
    end
end