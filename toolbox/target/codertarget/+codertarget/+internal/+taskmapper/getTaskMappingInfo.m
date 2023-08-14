function[mapData,eventNames]=getTaskMappingInfo(mdlName)




    if codertarget.utils.isMdlConfiguredForSoC(getActiveConfigSet(mdlName))
        [mapData,eventNames]=getSoCBInfo(mdlName);
    else
        [mapData,eventNames]=getTargetInfo(mdlName);
    end
end


function[mapData,eventNames]=getSoCBInfo(mdlName)
    mapData={};
    eventNames={};
    tskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(mdlName,true);
    if~iscell(tskMgrBlks),tskMgrBlks={tskMgrBlks};end
    if~isempty(tskMgrBlks)
        blkHandles=get_param(tskMgrBlks,'Handle');
        if iscell(blkHandles),blkHandles=cell2mat(blkHandles);end
        tskMgrBlksH=arrayfun(@(x)(get_param(x,'Object')),blkHandles);
        tskIdx=0;
        for blkIdx=1:numel(tskMgrBlksH)
            refMdl=soc.internal.connectivity.getModelConnectedToTaskManager(...
            tskMgrBlks{blkIdx});
            refMdlName=get_param(refMdl,'ModelName');
            load_system(refMdlName);
            hCS=getActiveConfigSet(get_param(refMdl,'ModelName'));
            puName=codertarget.targethardware.getProcessingUnitInfo(hCS);
            if isempty(puName)
                puName='CPU1';
            else
                puName=puName.Name;
            end
            blkData=tskMgrBlksH(blkIdx).AllTaskData;
            dm=soc.internal.TaskManagerData(blkData);
            allTaskNames=dm.getTaskNames;
            eventNames=codertarget.internal.taskmapper.getTaskEventSources(mdlName);
            for i=1:numel(allTaskNames)
                tskIdx=tskIdx+1;
                taskName=allTaskNames{i};
                taskData=dm.getTask(taskName);
                mapData{tskIdx,1}=taskName;%#ok<*AGROW>
                [found,idx]=ismember(taskData.taskEventSource,eventNames);
                if~found
                    eventNames{end+1}=taskData.taskEventSource;
                    idx=numel(eventNames);
                end
                mapData{tskIdx,2}=idx-1;
                mapData{tskIdx,3}=taskData.taskEventSourceAssignmentType;
                mapData{tskIdx,4}=taskData.taskEventSourceType;
                mapData{tskIdx,5}=puName;
            end
        end
    end
end


function[mapData,eventNames]=getTargetInfo(mdlName)
    mapData={};
    totTskIdx=0;
    allTaskNames=codertarget.internal.taskmapper.getHWITaskNames(mdlName);
    eventList=codertarget.internal.taskmapper.getDynamicEventSources(mdlName);
    hCS=getActiveConfigSet(mdlName);
    data=get_param(hCS,'CoderTargetData');
    if~isfield(data,'TaskMap')
        data.TaskMap.EventSources='unspecified';
    end
    hwiBlks=codertarget.internal.taskmapper.getHWIBlocksInModel(mdlName);
    initVal=struct('TaskPriority','','DisablePremption','','MappedSource',...
    'unspecified');
    for i=1:numel(allTaskNames)
        totTskIdx=totTskIdx+1;
        thisTask=allTaskNames{i};

        thisTask=strrep(thisTask,' ','');
        if isfield(data.TaskMap,'Tasks')
            storedTaskNames=fieldnames(data.TaskMap.Tasks);
            [found,~]=ismember(thisTask,storedTaskNames);
        else
            found=false;
        end
        if~found
            thisHWIBlk=hwiBlks{i};
            taskInfo=codertarget.internal.taskmapper.getHWITaskInfo(thisHWIBlk);
            data.TaskMap.Tasks.(thisTask)=initVal;
            data.TaskMap.Tasks.(thisTask).TaskPriority=taskInfo.TaskPriorites;
            data.TaskMap.Tasks.(thisTask).DisablePremption=taskInfo.DisablePreemption;
            evtId=1;
        else
            [foundEvt,evtId]=...
            ismember(data.TaskMap.Tasks.(thisTask).MappedSource,eventList);
            if~foundEvt
                evtId=1;
            end
        end
        mapData{totTskIdx,1}=thisTask;
        mapData{totTskIdx,2}=evtId-1;
        mapData{totTskIdx,3}='Manually assigned';
        mapData{totTskIdx,4}='unspecified';
        mapData{totTskIdx,5}='CPU1';
    end
    eventNames=eventList';



    set_param(hCS,'CoderTargetData',data);
end


