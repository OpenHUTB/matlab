function output=deleteEvolutions(obj,evolutionInfo)




    currentTree=obj.TreeListManager.CurrentSelected;

    [~,output]=evolutions.internal.deleteEvolutions(currentTree,evolutionInfo);

end

