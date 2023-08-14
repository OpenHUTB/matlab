function[status,errMsg]=taskManagerMapPreApplyCallback(h,hDlg)%#ok<INUSD>




    newBlkData={};
    for k=1:numel(h.TskMgrBlocks)
        blkData=h.TskMgrBlocks(k).AllTaskData;
        dmObj=soc.internal.TaskManagerData(blkData);
        allTaskNames=dmObj.getTaskNames;
        taskNames=h.taskMappingData(:,1);
        for i=1:numel(allTaskNames)
            task=allTaskNames{i};
            [~,idx1]=ismember(task,taskNames);
            srcIdx=h.taskMappingData{idx1,2}+1;
            evtSrc=h.eventList{srcIdx};
            type=h.taskMappingData{idx1,3};
            evtType=h.taskMappingData{idx1,4};
            updateTask(dmObj,task,'taskEventSource',evtSrc);
            updateTask(dmObj,task,'taskEventSourceType',evtType);
            updateTask(dmObj,task,'taskEventSourceAssignmentType',type);
        end
        newBlkData{k}=dmObj.getData;%#ok<AGROW>
        dataObj=soc.internal.TaskManagerData(newBlkData{k});
        errInfo=...
        soc.internal.taskmanager.verifyTaskToEventSourceAssignmentCore(...
        dataObj,h.TskMgrBlockHandles(k));
        if~isempty(errInfo)
            error(message(errInfo.ID,errInfo.Args{:}));
        end
    end

    for k=1:numel(h.TskMgrBlocks)
        blkData=h.TskMgrBlocks(k).AllTaskData;
        if~isequal(blkData,newBlkData{k})
            set_param(h.TskMgrBlockHandles(k),'AllTaskData',newBlkData{k});
        end
    end

    status=1;
    errMsg='';
end
