function onTaskTypeChange(hMask,hDlg,parameterName,newParameterValueIdx)




    validValues={'Event-driven','Timer-driven'};
    newParameterValue=validValues{newParameterValueIdx+1};
    hMask.onTaskParameterChange(hDlg,parameterName,newParameterValue);


    taskName=hMask.selectedTask;
    depParam1Name='taskEventSource';
    depParam2Name='taskEventSourceAssignmentType';
    dm=soc.internal.TaskManagerData(hMask.AllTaskData);
    if isequal(hMask.taskType,'Timer-driven')
        newDepParam1Value=DAStudio.message('codertarget:utils:InternalEvent');
        newDepParam2Value=DAStudio.message('codertarget:utils:AutoAssigned');
    else
        newDepParam1Value=DAStudio.message('codertarget:utils:UnspecifiedEvent');
        newDepParam2Value=DAStudio.message('codertarget:utils:Unassigned');
    end
    hMask.(depParam1Name)=newDepParam1Value;
    hMask.(depParam2Name)=newDepParam2Value;
    dm.updateTask(taskName,depParam1Name,newDepParam1Value);
    dm.updateTask(taskName,depParam2Name,newDepParam2Value);
    hMask.allTaskData=dm.getData;
    hMask.(depParam1Name)=newDepParam1Value;
    hMask.(depParam2Name)=newDepParam2Value;
end
