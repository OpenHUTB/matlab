function addFileToAllEvolutions(evolutionTreeInfo,files)




    bfis=evolutionTreeInfo.EvolutionManager.addFileToAllEvolutions(files);

    for idx=1:numel(bfis)
        bfi=bfis(idx);
        createArtifactForEvolution(evolutionTreeInfo,...
        evolutionTreeInfo.EvolutionManager.Infos,bfi);
    end

    evolutionTreeInfo.save;

    evolutions.internal.session.EventHandler.publish('FileListChanged',...
    evolutions.internal.ui.GenericEventData(evolutionTreeInfo));
end

function createArtifactForEvolution(evolutionTreeInfo,allEvolutions,bfi)

    for idx=1:numel(allEvolutions)
        evolution=allEvolutions(idx);
        if~(evolution.IsWorking)
            afi=evolutions.internal.artifactserver.createArtifacts(evolutionTreeInfo,bfi);

            evolution.addBaseFileAndArtifact(bfi,afi);
        else
            evolution.addBaseFile(bfi);
        end
    end
end
