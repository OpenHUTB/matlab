function createEvolution(currentTreeInfo,evolutionName,bfiToAfi)





    newEvolution=currentTreeInfo.EvolutionManager.promoteWorkingEvolution(evolutionName,bfiToAfi);


    workingEvolution=currentTreeInfo.EvolutionManager.create(newEvolution);


    currentTreeInfo.EdgeManager.addEdge(workingEvolution,newEvolution);

end
