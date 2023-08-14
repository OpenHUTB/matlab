function[filesAdded,filesRemoved]=syncActiveWithProject(evolutionTreeInfo)





    try

        evolutionManager=evolutionTreeInfo.EvolutionManager;
        activeEvolution=evolutionManager.WorkingEvolution;
        [filesRemoved,filesAdded]=...
        evolutions.internal.utils.getEvolutionToProjectDifference(activeEvolution);


        if~isempty(filesAdded)
            evolutions.internal.addFileToWorkingEvolution(evolutionTreeInfo,filesAdded);
        end


        if~isempty(filesRemoved)
            evolutions.internal.removeFileFromWorkingEvolution(evolutionTreeInfo,filesRemoved);
        end
    catch ME
        exception=MException...
        ('evolutions:manage:ActiveWithProjectSyncFail',getString(message...
        ('evolutions:manage:ActiveWithProjectSyncFail',ME.message)));
        exception=exception.addCause(ME);
        throw(exception);
    end
end
