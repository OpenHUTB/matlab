function tf=canAcceptDrop(obj,acceptNode,dropNode)




    tf=false;
    if~isa(dropNode,'cvi.ResultsExplorer.Node')||dropNode.data.marked
        return;
    end
    dropTree=dropNode.parentTree;
    acceptTree=getNodeTree(obj,acceptNode);
    tf=(acceptTree~=0)&&(dropTree~=acceptTree);
end