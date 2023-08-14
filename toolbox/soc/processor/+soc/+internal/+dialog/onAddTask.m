function onAddTask(hMask,hDlg)





    dm=soc.internal.TaskManagerData(hMask.allTaskData);
    allTaskNames=dm.getTaskNames;
    numTasks=numel(allTaskNames);

    nameIdx=1;
    addedTaskName=['newTask',num2str(nameIdx)];
    while ismember(addedTaskName,allTaskNames)
        nameIdx=nameIdx+1;
        addedTaskName=['newTask',num2str(nameIdx)];
    end

    val=get_param(hMask.BlockHandle,'supportEventPorts');
    supportsEventPorts=isequal(val,'on');
    dm.addNewTask(addedTaskName,supportsEventPorts);
    task=getTask(dm,addedTaskName);


    hMask.selectedTask=addedTaskName;
    hMask.taskList{numTasks+1}=addedTaskName;
    hMask.taskDurationData={'100','1e-06','0','1e-06','1e-06'};
    hMask.allTaskData=dm.getData;

    parameterNames=fieldnames(task);
    paramsToSkip=...
    {'coreSelection','taskDurationData','version'};
    for i=1:numel(parameterNames)
        if ismember(parameterNames{i},paramsToSkip),continue;end
        hMask.(parameterNames{i})=task.(parameterNames{i});
    end
    hDlg.enableApplyButton(true);
    hMask.updateWidgetValues(hDlg,task);
end