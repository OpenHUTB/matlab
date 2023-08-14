function edge=getEdgeInfo(obj,toEvolution,fromEvolution)




    currentTree=obj.TreeListManager.CurrentSelected;
    edgeManager=currentTree.EdgeManager;

    edge=edgeManager.findEdge(toEvolution,fromEvolution);
end
