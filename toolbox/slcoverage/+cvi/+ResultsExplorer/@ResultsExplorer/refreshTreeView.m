function refreshTreeView(obj)





    obj.imme.expandTreeNode(obj.root.passiveTree.interface);
    obj.imme.selectTreeViewNode(obj.root.activeTree.interface);
    h=obj.imme.getDialogHandle();
    if~isempty(h)
        h.refresh();
    end

    obj.ed.broadcastEvent('HierarchyChangedEvent',obj.root.passiveTree.interface);
    obj.ed.broadcastEvent('HierarchyChangedEvent',obj.root.activeTree.interface);
end