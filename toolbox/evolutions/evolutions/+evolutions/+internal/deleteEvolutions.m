function[success,evolutionsDeleted]=deleteEvolutions(currentTreeInfo,evolutionInfo)




    if nargin<2
        success=false;
        return
    end


    evolutionsToBeDeleted=evolutions.internal.utils.findEvolutionChildren(...
    currentTreeInfo.EvolutionManager,evolutionInfo);
    evolutionsToBeDeleted(end+1)=evolutionInfo;
    artifactIds=containers.Map;
    for idx=1:numel(evolutionsToBeDeleted)
        evolution=evolutionsToBeDeleted(idx);
        [~,artifacts]=evolutions.internal.utils.getBaseToArtifactsKeyValues(evolution);
        artifactIds(evolution.Id)=artifacts;
    end

    evolutionsDeleted=evolutions.internal.tree.utils.deleteEvolutions(currentTreeInfo,evolutionInfo);
    currentTreeInfo.save;


    keys=artifactIds.keys;
    for idx=1:numel(keys)
        artifactsToDelete=artifactIds(keys{idx});
        evolutions.internal.artifactserver.deleteArtifacts(currentTreeInfo,artifactsToDelete);
    end

    success=true;

    evolutions.internal.session.EventHandler.publish('TreeChanged',...
    evolutions.internal.ui.GenericEventData(currentTreeInfo));


