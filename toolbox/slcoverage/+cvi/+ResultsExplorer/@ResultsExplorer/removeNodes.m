function removeNodes(obj,nodes)




    for idx=1:numel(nodes)
        n=nodes(idx);
        tSynced=obj.synced;
        obj.synced=true;

        obj.deleteTreeNode(n,true);
        obj.synced=tSynced;
        obj.removeDataFromMaps(n.data);
        n.parentTree.removeTree(n);
    end
end