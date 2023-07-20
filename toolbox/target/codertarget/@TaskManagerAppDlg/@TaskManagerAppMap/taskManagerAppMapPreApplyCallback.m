function[status,errMsg]=taskManagerAppMapPreApplyCallback(h,hDlg)%#ok<INUSD>




    newBlkData={};
    isTskMgrBlk=contains(get_param(h.TskMgrBlockHandles(1),'MaskType'),'Task Manager');
    if isTskMgrBlk
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
    else
        thisMgr=h.TskMgrBlocks(1);
        mdlName=bdroot(thisMgr.getFullName);
        hCS=getActiveConfigSet(mdlName);
        data=get_param(hCS,'CoderTargetData');
        taskNames=h.taskMappingData(:,1);
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

        for k=1:numel(h.TskMgrBlocks)

            thisMgr=h.TskMgrBlocks(k);
            blkH=thisMgr.getFullName;
            taskInfo=codertarget.internal.taskmapper.findHWITaskInfo(blkH);

            if isfield(data.TaskMap,'Tasks')
                storedTaskNames=fieldnames(data.TaskMap.Tasks);
                [found,~]=ismember(taskNames{k},storedTaskNames);
            else
                found=0;
            end
            if~found

                thisTaskName=strrep(taskInfo.TaskNames,' ','');
                data.TaskMap.Tasks.(thisTaskName)=struct('TaskPriority','','DisablePremption','','MappedSource','unspecified');
                data.TaskMap.Tasks.(thisTaskName).TaskPriority=taskInfo.TaskPriorites;
                data.TaskMap.Tasks.(thisTaskName).DisablePremption=taskInfo.DisablePreemption;
                srcIdx=h.taskMappingData{k,2}+1;
                evtSrc=h.eventList{srcIdx};
                data.TaskMap.Tasks.(thisTaskName).MappedSource=evtSrc;
            else
                srcIdx=h.taskMappingData{k,2}+1;
                evtSrc=h.eventList{srcIdx};
                data.TaskMap.Tasks.(taskNames{k}).MappedSource=evtSrc;
                data.TaskMap.Tasks.(taskNames{k}).TaskPriority=taskInfo.TaskPriorites;
            end

        end
        set_param(hCS,'CoderTargetData',data);
        status=1;
        errMsg='';
    end
