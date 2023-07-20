function taskName=getMappedTaskName(ModelName,TskMgrTaskName)




    TasMgrBlock=soc.internal.connectivity.getTaskManagerBlock(ModelName,'overrideAssert');
    if~iscell(TasMgrBlock)
        TasMgrBlock={TasMgrBlock};
    end
    for i=1:numel(TasMgrBlock)
        TaskMgrData=soc.internal.TaskManagerData(get_param(TasMgrBlock{i},'AllTaskData'));

        if any(strcmp(TaskMgrData.getTaskNames,TskMgrTaskName))
            TaskDetails=getTask(TaskMgrData,TskMgrTaskName);
            if~isequal(TaskDetails.taskEventSource,'Unspecified')&&~isequal(TaskDetails.taskEventSource,'Internal')
                taskName=TaskDetails.taskEventSource;
                break;
            else
                taskName='';
            end
        else
            taskName='';
        end
    end
end
