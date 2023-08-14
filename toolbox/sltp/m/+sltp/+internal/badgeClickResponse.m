function badgeClickResponse(blockHandle,partitionString)




    modelHandle=bdroot(blockHandle);
    if bdIsSubsystem(modelHandle)||bdIsLibrary(modelHandle)
        allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
        if~isempty(allStudios)
            studio=allStudios(1);
            editor=studio.App.getActiveEditor();

            editor.deliverInfoNotification('SimulinkPartitioning:Badges:ScheduleEditorOpensInSimulinkModelsOnly',...
            DAStudio.message('SimulinkPartitioning:Badges:ScheduleEditorOpensInSimulinkModelsOnly'));
        end
        return;
    end
    if modelIsStopped(modelHandle)
        tcg=sltp.TaskConnectivityGraph(modelHandle);
        tasks=tcg.getExportedTasks(partitionString);

        sltp.internal.open_partition(modelHandle,tasks);
    end
end

function isStopped=modelIsStopped(model)
    isStopped=strcmpi(get_param(model,'SimulationStatus'),'stopped');
end


