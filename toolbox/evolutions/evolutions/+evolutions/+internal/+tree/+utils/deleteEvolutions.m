function evolutionsDeleted=deleteEvolutions(currentTreeInfo,evolutionInfo)





    evolutionsDeleted=currentTreeInfo.EdgeManager.removeEvolutionBranch(evolutionInfo,currentTreeInfo.EvolutionManager);

    if~isequal(currentTreeInfo.RootEvolution,currentTreeInfo.EvolutionManager.RootEvolution)
        currentTreeInfo.setRoot(currentTreeInfo.EvolutionManager.RootEvolution);
    end


