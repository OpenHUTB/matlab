function[success,output]=getEvolution(currentTreeInfo,evolutionInfo)




    output=struct('message','');

    if nargin<2
        success=false;
        return
    end


    if~doReferenceProjectReadOnlyCheck(currentTreeInfo,evolutionInfo)
        projectReadOnlyMessage=getString(message('MATLAB:project:api:ReadOnlyReferencedProject'));
        errorMessage=getString(message...
        ('evolutions:manage:GetEvolutionApiError',evolutionInfo.getName,projectReadOnlyMessage));
        exception=MException('evolutions:manage:TreeDataWriteFail',errorMessage);
        throw(exception);
    end


    evolutions.internal.syncActiveWithProject(currentTreeInfo);

    evolutions.internal.tree.utils.getEvolution(currentTreeInfo,evolutionInfo);

    currentTreeInfo.save;


    bfis=evolutionInfo.Infos;
    fh=evolutions.internal.FileTypeHandler;
    for bfiIdx=1:bfis.Size
        curBfi=bfis(bfiIdx);
        fh.closeElements(curBfi.File);
    end


    evolutions.internal.artifactserver.getArtifacts(currentTreeInfo,currentTreeInfo.EvolutionManager.CurrentEvolution);


    evolutions.internal.syncProjectWithEvolutionTree(currentTreeInfo);

    success=true;

    evolutions.internal.session.EventHandler.publish('TreeChanged',...
    evolutions.internal.ui.GenericEventData(currentTreeInfo));
end

function tf=doReferenceProjectReadOnlyCheck(currentTreeInfo,evolutionInfo)
    project=currentTreeInfo.Project;


    if project.TopLevel
        tf=true;
        return;
    else


        filesToAdd=evolutions.internal.utils.getEvolutionToProjectDifference(evolutionInfo);
        tf=isempty(filesToAdd);
        return;
    end
end
