function[success,output]=updateEvolution(treeId)

    treeInfo=evolutions.internal.getDataObject(treeId);

    [success,output]=evolutions.internal.updateEvolution(treeInfo);
end
