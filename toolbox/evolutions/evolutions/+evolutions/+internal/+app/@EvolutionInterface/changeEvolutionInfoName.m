function changeEvolutionInfoName(obj,evolutionInfo,name)




    treeListManager=getSubModel(obj.AppModel,'EvolutionTreeListManager');
    treeInfo=treeListManager.CurrentSelected;
    evolutions.internal.changeEvolutionName(treeInfo,evolutionInfo,name);
end
