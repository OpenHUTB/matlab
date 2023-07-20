function getEvolution(currentTreeInfo,evolutionInfo)






    currentTreeInfo.EvolutionManager.getEvolution(evolutionInfo);


    workingEvolution=currentTreeInfo.EvolutionManager.WorkingEvolution;
    currentEvolution=workingEvolution.Parent;

    currentTreeInfo.EdgeManager.removeEdge(workingEvolution,currentEvolution);
    currentTreeInfo.EdgeManager.addEdge(workingEvolution,evolutionInfo);
