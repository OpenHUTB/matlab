function taskNames=getEventDrivenProxyTaskNames(modelName)




    import soc.internal.connectivity.*

    taskMgrBlk=getTaskManagerBlock(modelName);
    allTaskData=get_param(taskMgrBlk,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData);
    allTasks=dm.getTask(dm.getTaskNames);
    allTskIdx=arrayfun(@(x)contains(x.taskType,'Event-driven'),allTasks);
    taskNames={};
    if~isempty(allTskIdx)
        allTasks=allTasks(allTskIdx);
        allTaskNames={allTasks.taskName};
        for i=1:numel(allTaskNames)
            if isProxyTask(modelName,allTaskNames{i})
                taskNames{end+1}=allTaskNames{i};%#ok<AGROW>
            end
        end
    end
end
