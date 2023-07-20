function deleteSingleEvolution(currentTreeInfo,evolutionInfo)




    currentTreeInfo.EdgeManager.removeEvolution(evolutionInfo,currentTreeInfo.EvolutionManager);


    if~isequal(currentTreeInfo.RootEvolution,currentTreeInfo.EvolutionManager.RootEvolution)
        currentTreeInfo.setRoot(currentTreeInfo.EvolutionManager.RootEvolution);
    end


