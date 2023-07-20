function addCallback(topModelName)




    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    if~isempty(node)
        obj=node.parentTree.resultsExplorer;
        obj.acceptDrop(obj.root.activeTree.root,node);
        obj.handleModelAttachedFilter(node);
        obj.ed.broadcastEvent('HierarchyChangedEvent',obj.root.interface);


    end
end