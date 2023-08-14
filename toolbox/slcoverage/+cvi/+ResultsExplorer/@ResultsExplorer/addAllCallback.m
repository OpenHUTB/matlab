function addAllCallback(topModelName)





    node=cvi.ResultsExplorer.ResultsExplorer.activeNode(topModelName);
    if~isempty(node)
        obj=node.parentTree.resultsExplorer;
        for idx=1:numel(node.children)
            childNode=node.children{idx};
            obj.acceptDrop(obj.root.activeTree.root,childNode);
            obj.handleModelAttachedFilter(childNode);
            obj.ed.broadcastEvent('HierarchyChangedEvent',obj.root.interface);
        end
    end
end