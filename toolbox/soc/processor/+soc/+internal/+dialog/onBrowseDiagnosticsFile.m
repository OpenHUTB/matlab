function onBrowseDiagnosticsFile(hMask,hDlg)







    [fName,fPath]=uigetfile({'*.csv','Diagnostics data'},...
    'Select diagnostics file');

    if fName~=0
        taskName=hMask.taskName;
        parameterName='diagnosticsFile';
        diagnosticsFile=fullfile(fPath,fName);
        dm=soc.internal.TaskManagerData(hMask.AllTaskData);
        dm.updateTask(taskName,parameterName,diagnosticsFile);
        hMask.allTaskData=dm.getData;
        hMask.diagnosticsFile=diagnosticsFile;
        if~hMask.playbackRecorded
            soc.internal.getTaskDurationFromDiagnosticsFile(...
            taskName,diagnosticsFile,'');
        end
    end
    hDlg.enableApplyButton(true);
end