function updateTaskDurationData(hMask,hDlg)%#ok<INUSD>




    taskName=hMask.selectedTask;
    dm=soc.internal.TaskManagerData(hMask.AllTaskData);


    durationDistrData=hMask.taskDurationData;
    [nDistributions,~]=size(durationDistrData);
    for distIdx=1:nDistributions
        newData(distIdx).percent=durationDistrData(distIdx,1);%#ok<*AGROW>
        newData(distIdx).mean=durationDistrData(distIdx,2);
        newData(distIdx).dev=durationDistrData(distIdx,3);
        newData(distIdx).min=durationDistrData(distIdx,4);
        newData(distIdx).max=durationDistrData(distIdx,5);
    end
    dm.updateTask(taskName,'taskDurationData',newData);
    hMask.allTaskData=dm.getData;
end