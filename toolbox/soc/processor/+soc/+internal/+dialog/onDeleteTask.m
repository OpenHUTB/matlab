function onDeleteTask(hMask,hDlg)




    deletedTaskName=hMask.selectedTask;
    if isempty(deletedTaskName),return;end
    [~,taskIdx]=ismember(deletedTaskName,hMask.taskList);
    dm=soc.internal.TaskManagerData(hMask.allTaskData);
    dm.deleteTask(deletedTaskName);


    updateTaskEditData(hMask,deletedTaskName);


    allTaskNames=dm.getTaskNames;
    hMask.taskList=allTaskNames;
    hMask.allTaskData=dm.getData;

    assert(~isempty(allTaskNames),'Task list cannot be empty');


    if taskIdx>numel(allTaskNames),taskIdx=taskIdx-1;end
    selectedTaskName=allTaskNames{taskIdx};
    hMask.selectedTask=selectedTaskName;
    task=getTask(dm,selectedTaskName);
    parameterNames=fieldnames(task);
    parametersToSkip={'coreSelection','version'};
    for i=1:numel(parameterNames)
        pName=parameterNames{i};
        if ismember(pName,parametersToSkip),continue;end
        if isequal(pName,'taskDurationData')
            dd=task.taskDurationData;
            [nRegions,~]=size(dd);
            hMask.(pName)={};
            for regionIdx=1:nRegions
                hMask.(pName){regionIdx,1}=iGetNonCellValue(dd(regionIdx).percent);
                hMask.(pName){regionIdx,2}=iGetNonCellValue(dd(regionIdx).mean);
                hMask.(pName){regionIdx,3}=iGetNonCellValue(dd(regionIdx).dev);
                hMask.(pName){regionIdx,4}=iGetNonCellValue(dd(regionIdx).min);
                hMask.(pName){regionIdx,5}=iGetNonCellValue(dd(regionIdx).max);
            end
        else
            hMask.(pName)=task.(pName);
        end
    end

    hDlg.enableApplyButton(true);
    hMask.updateWidgetValues(hDlg,task);


    function val=iGetNonCellValue(val)
        if iscell(val)
            val=val{1};
        end
    end
end


function updateTaskEditData(hMask,deletedTaskName)
    rawData=hMask.taskEditData;
    taskEditData=jsondecode(rawData);
    if~isequal(taskEditData,struct())&&isfield(taskEditData,'renamed')
        for i=1:numel(taskEditData.renamed)
            if isequal(taskEditData.renamed(i).newName,deletedTaskName)
                taskEditData.renamed(i)=[];
                if isempty(taskEditData.renamed)
                    taskEditData=rmfield(taskEditData,'renamed');
                end
                hMask.taskEditData=jsonencode(taskEditData);
                break;
            end
        end
    end
end
