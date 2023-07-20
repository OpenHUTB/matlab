function differences=calculateEvolutionDifferences(obj,evolution1,evolution2)





    currentTree=obj.TreeListManager.CurrentSelected;
    differences=evolutions.internal.utils.calculateEvolutionDifferences(currentTree,evolution1,evolution2);
end
