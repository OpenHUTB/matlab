function removeFileFromAllEvolutions(evolutionTreeInfo,files)





    artifactIds=evolutionTreeInfo.EvolutionManager.getArtifactIdsForFile(files);

    evolutionTreeInfo.EvolutionManager.removeFileFromAllEvolutions(files);

    evolutionTreeInfo.save;


    evolutions.internal.artifactserver.deleteArtifacts(evolutionTreeInfo,artifactIds);


    evolutions.internal.session.EventHandler.publish('FileListChanged',...
    evolutions.internal.ui.GenericEventData(evolutionTreeInfo));
end

