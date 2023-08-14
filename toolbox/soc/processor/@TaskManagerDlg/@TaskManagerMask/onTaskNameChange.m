function onTaskNameChange(hMask,hDlg,parameterName,newTaskName)





    mdlName=get_param(0,'CurrentSystem');
    if~iscvar(newTaskName)||(strlength(newTaskName)>55)||(newTaskName(1)=='_')
        msg=DAStudio.message('soc:scheduler:InvalidTaskName',newTaskName,...
        hMask.selectedTask);
        hMask.taskName=hMask.selectedTask;
        warning(msg);
    elseif ismember(newTaskName,hMask.taskList)
        msg=DAStudio.message('soc:scheduler:NonuniqueTaskNames',newTaskName,...
        hMask.selectedTask);
        hMask.taskName=hMask.selectedTask;
        warning(msg);
    elseif isequal(newTaskName,mdlName)
        warning(message('soc:scheduler:TaskNameModelNameSame',newTaskName,...
        hMask.selectedTask));
        hMask.taskName=hMask.selectedTask;
    else
        updateTaskEditData(hMask,newTaskName);
        hMask.onTaskParameterChange(hDlg,parameterName,newTaskName);
        hMask.selectedTask=newTaskName;
        dm=soc.internal.TaskManagerData(hMask.AllTaskData);
        hMask.taskList=dm.getTaskNames;
    end
    hDlg.setWidgetValue('taskNameTag',hMask.taskName);
end


function updateTaskEditData(hMask,newTaskName)
    rawData=hMask.taskEditData;
    taskEditData=jsondecode(rawData);
    if isequal(taskEditData,struct())||~isfield(taskEditData,'renamed')
        taskEditData.renamed(1).oldName=hMask.selectedTask;
        taskEditData.renamed(1).newName=newTaskName;
    else

        isdone=false;
        numRT=numel(taskEditData.renamed);
        for i=1:numRT
            if isequal(taskEditData.renamed(i).newName,hMask.selectedTask)
                taskEditData.renamed(i).oldName=hMask.selectedTask;
                taskEditData.renamed(i).newName=newTaskName;
                isdone=true;
                break;
            end
        end
        if~isdone
            taskEditData.renamed(numRT+1).oldName=hMask.selectedTask;
            taskEditData.renamed(numRT+1).newName=newTaskName;
        end
    end
    hMask.taskEditData=jsonencode(taskEditData);
end
