function onTaskSelectionChange(hMask,hDlg,paramName,taskIdx)%#ok<INUSL>




    if isempty(taskIdx)
        return;
    end

    selectedTaskName=hMask.taskList{taskIdx+1};
    hMask.selectedTask=selectedTaskName;
    dm=soc.internal.TaskManagerData(hMask.AllTaskData);
    task=dm.getTask(selectedTaskName);

    hMask.playbackRecorded=task.playbackRecorded;

    dd=task.taskDurationData;
    [nRegions,~]=size(dd);
    hMask.taskDurationData={};
    for regionIdx=1:nRegions
        hMask.taskDurationData{regionIdx,1}=iGetNonCellValue(dd(regionIdx).percent);
        hMask.taskDurationData{regionIdx,2}=iGetNonCellValue(dd(regionIdx).mean);
        hMask.taskDurationData{regionIdx,3}=iGetNonCellValue(dd(regionIdx).dev);
        hMask.taskDurationData{regionIdx,4}=iGetNonCellValue(dd(regionIdx).min);
        hMask.taskDurationData{regionIdx,5}=iGetNonCellValue(dd(regionIdx).max);
    end

    parameterNames=fieldnames(task);
    for i=1:numel(parameterNames)
        parametersToSkip={'coreSelection','version','taskDurationData'};
        if ismember(parameterNames{i},parametersToSkip),continue;end
        hMask.(parameterNames{i})=task.(parameterNames{i});
    end
    hMask.updateWidgetValues(hDlg,task);


    function val=iGetNonCellValue(val)
        if iscell(val)
            val=val{1};
        end
    end
end
