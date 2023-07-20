function removeFileFromWorkingEvolution(evolutionTreeInfo,files)





    evolutionTreeInfo.EvolutionManager.removeWorkingFile(files);

    evolutionTreeInfo.save;

    evolutions.internal.session.EventHandler.publish('FileListChanged',...
    evolutions.internal.ui.GenericEventData(evolutionTreeInfo));
end
