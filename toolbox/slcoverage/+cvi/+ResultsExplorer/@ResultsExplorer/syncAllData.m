function syncAllData(obj)




    removeIncompatibleData(obj);
    obj.synced=false;
    loadAllData(obj);
    obj.imme.expandTreeNode(obj.root.passiveTree.interface);
    obj.ed.broadcastEvent('HierarchyChangedEvent',obj.root.passiveTree.interface);
end