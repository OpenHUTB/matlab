function applyMappingData(mdlName,taskMappingData,eventList)




    taskMgrBlks={};
    if codertarget.utils.isMdlConfiguredForSoC(getActiveConfigSet(mdlName))
        taskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(mdlName,true);
        if~iscell(taskMgrBlks),taskMgrBlks={taskMgrBlks};end
    end

    if~isempty(taskMgrBlks)
        applyForSoCB(taskMgrBlks,taskMappingData,eventList);
    else
        applyForTarget(mdlName,taskMappingData,eventList);
    end
end


function applyForSoCB(taskMgrBlks,taskMappingData,eventList)
    newBlkData={};
    for k=1:numel(taskMgrBlks)
        blkData=get_param(taskMgrBlks{k},'AllTaskData');
        dm=soc.internal.TaskManagerData(blkData);
        allTaskNames=dm.getTaskNames;
        taskNames=taskMappingData(:,1);
        for i=1:numel(allTaskNames)
            task=allTaskNames{i};
            [~,idx1]=ismember(task,taskNames);
            srcIdx=taskMappingData{idx1,2}+1;
            evtSrc=eventList{srcIdx};
            type=taskMappingData{idx1,3};
            evtType=taskMappingData{idx1,4};
            dm.updateTask(task,'taskEventSource',evtSrc);
            dm.updateTask(task,'taskEventSourceType',evtType);
            dm.updateTask(task,'taskEventSourceAssignmentType',type);
        end
        newBlkData{k}=dm.getData;%#ok<AGROW>
        blkData=get_param(taskMgrBlks{k},'AllTaskData');
        if~isequal(blkData,newBlkData{k})
            set_param(taskMgrBlks{k},'AllTaskData',newBlkData{k});
        end
    end
end


function applyForTarget(mdlName,taskMappingData,eventList)
    hCS=getActiveConfigSet(mdlName);
    data=get_param(hCS,'CoderTargetData');
    taskNames=taskMappingData(:,1);
    taskNames=strrep(taskNames,' ','');
    if isfield(data.TaskMap,'Tasks')
        storedTaskNames=fieldnames(data.TaskMap.Tasks);
        for i=1:numel(storedTaskNames)

            storedTask=storedTaskNames{i};
            [found,~]=ismember(storedTask,taskNames);
            if~found

                data.TaskMap.Tasks=rmfield(data.TaskMap.Tasks,storedTask);
            end
        end
    end
    hwiBlks=codertarget.internal.taskmapper.getHWIBlocksInModel(mdlName);
    initVal=struct('TaskPriority','','DisablePremption','','MappedSource',...
    'unspecified');
    for k=1:numel(hwiBlks)

        thisHWIBlk=hwiBlks{k};
        taskInfo=codertarget.internal.taskmapper.getHWITaskInfo(thisHWIBlk);
        if isfield(data.TaskMap,'Tasks')
            storedTaskNames=fieldnames(data.TaskMap.Tasks);
            [found,~]=ismember(taskNames{k},storedTaskNames);
        else
            found=0;
        end
        if~found
            thisTask=strrep(taskInfo.TaskNames,' ','');
            data.TaskMap.Tasks.(thisTask)=initVal;
            data.TaskMap.Tasks.(thisTask).DisablePremption=taskInfo.DisablePreemption;
            srcIdx=taskMappingData{k,2}+1;
            data.TaskMap.Tasks.(thisTask).MappedSource=eventList{srcIdx};
            data.TaskMap.Tasks.(thisTask).TaskPriority=taskInfo.TaskPriorites;
        else
            srcIdx=taskMappingData{k,2}+1;
            data.TaskMap.Tasks.(taskNames{k}).MappedSource=eventList{srcIdx};
            data.TaskMap.Tasks.(taskNames{k}).TaskPriority=taskInfo.TaskPriorites;
        end
    end
    set_param(hCS,'CoderTargetData',data);
end

