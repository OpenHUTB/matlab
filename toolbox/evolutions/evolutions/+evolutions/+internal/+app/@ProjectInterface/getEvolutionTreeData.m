function[root,allNodes]=getEvolutionTreeData(~,evolutionTree)




    root=[];
    allNodes=[];
    if isempty(evolutionTree)
        return;
    end
    tree=evolutionTree.EvolutionManager;
    if~isempty(tree)
        root=tree.RootEvolution;
        allNodes=tree.Infos;
    end
end
