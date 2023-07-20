function working=getEvolutionTreeWorkingNode(~,evolutionTree)





    working=[];
    if~isempty(evolutionTree)

        tree=evolutionTree.EvolutionManager;
        working=tree.WorkingEvolution;
    end
end
