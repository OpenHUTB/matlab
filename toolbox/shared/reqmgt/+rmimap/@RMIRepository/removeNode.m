function wasRemoved=removeNode(this,rootName,nodeId)






    myRoot=rmimap.RMIRepository.getRoot(this.graph,rootName);
    if isempty(myRoot)
        wasRemoved=false;
    else
        node=rmimap.RMIRepository.getNode(myRoot,nodeId);
        if isempty(node)
            wasRemoved=false;
        else
            t1=M3I.Transaction(this.graph);
            this.clearLinks(node,true);
            if~isempty(node.data)
                node.data.destroy;
            end
            node.destroy;
            t1.commit;
            wasRemoved=true;
        end
    end
end


