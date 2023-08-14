function errInfo=preApplyCheck(model,taskMappingData,eventList)




    taskMgrBlks={};
    if codertarget.utils.isMdlConfiguredForSoC(getActiveConfigSet(model))
        taskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(model,true);
        if~iscell(taskMgrBlks),taskMgrBlks={taskMgrBlks};end
    end

    if~isempty(taskMgrBlks)
        errInfo=verifyForSoCB(taskMgrBlks,taskMappingData,eventList);
    else
        errInfo=verifyForTarget(model);
    end
end


function errInfo=verifyForSoCB(taskMgrBlks,taskMappingData,eventList)
    errInfo={};
    newBlkData={};
    taskMgrBlkHandles=cellfun(@(x)get_param(x,'Handle'),taskMgrBlks,...
    'UniformOutput',true);
    for k=1:numel(taskMgrBlks)
        blkData=get_param(taskMgrBlks{k},'AllTaskData');
        dmObj=soc.internal.TaskManagerData(blkData);
        allTaskNames=dmObj.getTaskNames;
        taskNames=taskMappingData(:,1);
        for i=1:numel(allTaskNames)
            task=allTaskNames{i};
            [~,idx1]=ismember(task,taskNames);
            srcIdx=taskMappingData{idx1,2}+1;
            evtSrc=eventList{srcIdx};
            type=taskMappingData{idx1,3};
            evtType=taskMappingData{idx1,4};
            updateTask(dmObj,task,'taskEventSource',evtSrc);
            updateTask(dmObj,task,'taskEventSourceType',evtType);
            updateTask(dmObj,task,'taskEventSourceAssignmentType',type);
        end
        newBlkData{k}=dmObj.getData;%#ok<AGROW>
        dataObj=soc.internal.TaskManagerData(newBlkData{k});
        errInfo{k}=...
        soc.internal.taskmanager.verifyTaskToEventSourceAssignmentCore(...
        dataObj,taskMgrBlkHandles(k));%#ok<AGROW> 
    end
end


function errInfo=verifyForTarget(model)%#ok<INUSD> 
    errInfo={};
end

