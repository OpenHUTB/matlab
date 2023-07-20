function onTaskParameterChange(hMask,hDlg,parameterName,newParameterValue)%#ok<INUSL>





    taskName=hMask.selectedTask;
    dm=soc.internal.TaskManagerData(hMask.AllTaskData);
    task=dm.updateTask(taskName,parameterName,newParameterValue);
    if isequal(hMask.get_param('SupportEventPorts'),'on')&&isequal(task.taskType,'Event-driven')
        hMask.taskEvent=dm.setEventNameBasedOnTask(task.taskName);
    end
    hMask.allTaskData=dm.getData;
    hMask.(parameterName)=newParameterValue;
end
