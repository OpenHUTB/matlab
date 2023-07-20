function node=findOrAddNode(this,rootUrl,nodeId,docKind)




    myRoot=this.findOrAddRoot(rootUrl,docKind);

    if isempty(nodeId)
        node=myRoot;
    else

        node=rmimap.RMIRepository.getNode(myRoot,nodeId);
        if isempty(node)
            node=this.addNode(myRoot,nodeId);
        end
    end
end


