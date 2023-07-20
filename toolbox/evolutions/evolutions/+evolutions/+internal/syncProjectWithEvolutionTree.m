function[filesAdded,filesRemoved]=syncProjectWithEvolutionTree(currentTreeInfo)









    project=currentTreeInfo.Project;
    evolutionManager=currentTreeInfo.EvolutionManager;
    activeEvolution=evolutionManager.WorkingEvolution;
    [filesAdded,filesRemoved]=...
    evolutions.internal.utils.getEvolutionToProjectDifference(activeEvolution);

    if(~isempty(filesAdded)||~isempty(filesRemoved))

        pm=evolutions.internal.project.ProjectManager.get;
        catalog=pm.ProjectObserverCatalog;
        catalog.removeProjectObserver(project.RootFolder);


        cleanup=onCleanup(@()catalog.addProjectObserver(project.RootFolder));

        for idx=1:numel(filesAdded)
            project.addFile(filesAdded{idx});
        end

        for idx=1:numel(filesRemoved)
            project.removeFile(filesRemoved{idx});
        end


        evolutions.internal.project.ProjectManager.syncProjectFiles(project.RootFolder);
    end

end
