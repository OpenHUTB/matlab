function node=findNode(obj,uuid)




    nodes=obj.root.activeTree.getAllNodes(obj.root.activeTree.root.children);
    idx=find(cellfun(@(x)(x.uuid==string(uuid)),nodes));
    node=nodes{idx};

end