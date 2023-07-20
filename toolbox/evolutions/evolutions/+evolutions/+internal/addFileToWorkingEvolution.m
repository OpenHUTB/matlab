function addFileToWorkingEvolution(evolutionTreeInfo,files)





    bfi=evolutionTreeInfo.EvolutionManager.addWorkingFile(files);
    if~isempty(bfi)
        evolutionTreeInfo.save;

        evolutions.internal.session.EventHandler.publish('FileListChanged',...
        evolutions.internal.ui.GenericEventData(evolutionTreeInfo));
    end
end
