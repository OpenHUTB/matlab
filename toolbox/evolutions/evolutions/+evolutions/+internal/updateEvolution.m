function[success,output]=updateEvolution(currentTreeInfo)



    output=struct('message','');

    if nargin<1
        success=false;
        return
    end


    evolutions.internal.syncActiveWithProject(currentTreeInfo);

    bfiToAfi=containers.Map;
    bfis=evolutions.internal.utils.getBaseToArtifactsKeyValues...
    (currentTreeInfo.EvolutionManager.WorkingEvolution);
    for idx=1:numel(bfis)
        bfi=bfis(idx);
        afi=evolutions.internal.artifactserver.createArtifacts(currentTreeInfo,bfi);
        bfiToAfi(bfi.Id)=afi;
    end



    [~,artifactIds]=evolutions.internal.utils.getBaseToArtifactsKeyValues(currentTreeInfo.EvolutionManager.CurrentEvolution);

    currentTreeInfo.EvolutionManager.updateCurrentEvolution(bfiToAfi);

    currentTreeInfo.save;


    evolutions.internal.artifactserver.deleteArtifacts(currentTreeInfo,artifactIds);
    success=true;


    evolutions.internal.session.EventHandler.publish('TreeChanged',...
    evolutions.internal.ui.GenericEventData(currentTreeInfo));
end


