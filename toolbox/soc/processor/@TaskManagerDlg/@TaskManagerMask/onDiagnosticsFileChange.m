function onDiagnosticsFileChange(hMask,hDlg,parameterName,newFileName)




    taskName=hMask.selectedTask;
    if~exist(newFileName,'file')

        msg=DAStudio.message('soc:scheduler:DiagFileNotFound',newFileName,...
        taskName);
        hMask.taskName=hMask.selectedTask;
        warning(msg);
        dm=soc.internal.TaskManagerData(hMask.AllTaskData);
        curFileName=dm.getTask(hMask.selectedTask).diagnosticsFile;
        newFileName=curFileName;
        hDlg.setWidgetValue('diagnosticsFileTag',curFileName);
    end
    dm=soc.internal.TaskManagerData(hMask.AllTaskData);
    dm.updateTask(taskName,parameterName,newFileName);
    hMask.allTaskData=dm.getData;
    hMask.(parameterName)=newFileName;
end
