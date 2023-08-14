function hDlg=TaskManagerMask(block)

















































    hDlg=TaskManagerDlg.TaskManagerMask(block);

    hDlg.Block=get_param(block,'Object');
    hDlg.BlockHandle=block;
    blockData=hDlg.Block.AllTaskData;
    dm=soc.internal.TaskManagerData(blockData);
    allTaskNames=dm.getTaskNames;

    hDlg.customizationInfo=soc.internal.taskmanager.getCustomizationInfo(block);



    hDlg.enableTaskSimulation=isequal(hDlg.Block.EnableTaskSimulation,'on');
    hDlg.useScheduleEditor=isequal(hDlg.Block.UseScheduleEditor,'on');
    hDlg.streamToSDI=isequal(hDlg.Block.StreamToSDI,'on');
    hDlg.writeToFile=isequal(hDlg.Block.WriteToFile,'on');
    hDlg.overwriteFile=isequal(hDlg.Block.OverwriteFile,'on');
    hDlg.taskEditData='{}';
    hDlg.allTaskData=dm.getData;
    hDlg.taskList=allTaskNames;

    if~isempty(allTaskNames)
        locSetTaskDurationDataDialogValuesFromFirstTask(hDlg,dm);
    end

    if~isempty(allTaskNames)
        locSetTaskDataDialogValuesFromFirstTask(hDlg,dm);
    end

    parent=hDlg.Block.getParent;
    while~isa(parent,'Simulink.BlockDiagram')
        parent=parent.getParent;
    end
    hDlg.Root=parent;
end


function locSetTaskDataDialogValuesFromFirstTask(hDlg,dm)
    tskIdx=1;
    allTaskNames=dm.getTaskNames;
    taskName=allTaskNames{tskIdx};
    hDlg.selectedTask=taskName;
    task=dm.getTask(taskName);
    parameterNames=fieldnames(task);
    for i=1:numel(parameterNames)
        paramsToSkip=...
        {'coreSelection','taskDurationData','version'};
        if ismember(parameterNames{i},paramsToSkip),continue;end
        hDlg.(parameterNames{i})=task.(parameterNames{i});
    end
end


function locSetTaskDurationDataDialogValuesFromFirstTask(hDlg,dm)
    tskIdx=1;
    hDlg.selectedTableRow=1;
    allTaskNames=dm.getTaskNames;
    task1Data=dm.getTask(allTaskNames{tskIdx});
    savedData=task1Data.taskDurationData;
    for idx=1:length(savedData)
        dlgData{idx,1}=iGetNonCellValue(savedData(idx).percent);%#ok<*AGROW>
        dlgData{idx,2}=iGetNonCellValue(savedData(idx).mean);
        dlgData{idx,3}=iGetNonCellValue(savedData(idx).dev);
        dlgData{idx,4}=iGetNonCellValue(savedData(idx).min);
        dlgData{idx,5}=iGetNonCellValue(savedData(idx).max);
    end
    hDlg.taskDurationData=dlgData;

    function val=iGetNonCellValue(val)
        if iscell(val)
            val=val{1};
        end
    end
end
