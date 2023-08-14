function output=deleteSingleEvolution(obj,evolutionInfo)




    currentTree=obj.TreeListManager.CurrentSelected;

    [~,output]=evolutions.internal.deleteSingleEvolution(currentTree,evolutionInfo);

end

