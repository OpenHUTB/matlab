function[mapData,eventNames]=autoassignTaskToEventSource(mdlName,mapData,eventNames)




    taskMgrBlks={};
    if codertarget.utils.isMdlConfiguredForSoC(getActiveConfigSet(mdlName))
        taskMgrBlks=soc.internal.connectivity.getTaskManagerBlock(mdlName,true);
        if~iscell(taskMgrBlks),taskMgrBlks={taskMgrBlks};end
    end
    if isempty(taskMgrBlks)
        return
    end

    mappedTaskNames=mapData(:,1);
    assignType=DAStudio.message('codertarget:utils:AutoAssigned');
    for i=1:numel(taskMgrBlks)
        tskMgr=taskMgrBlks{i};
        allTskNames=soc.internal.taskmanager.getEventDrivenTaskNames(tskMgr);
        for j=1:numel(allTskNames)
            task=allTskNames{j};
            [evtSrc,evtType]=...
            soc.internal.taskmanager.getEventSourceBlockForTask(tskMgr,task);
            if isequal(evtType,'Event Source'),continue;end
            if isempty(evtSrc),continue;end
            evtSrcName=get_param(evtSrc,'Name');
            [~,tskIdx]=ismember(task,mappedTaskNames);
            [found,evtIdx]=ismember(evtSrcName,eventNames);
            if~found


                evtIdx=numel(eventNames)+1;
                eventNames{evtIdx}=evtSrcName;
            end
            mapData{tskIdx,2}=evtIdx-1;
            mapData{tskIdx,3}=assignType;
            mapData{tskIdx,4}=evtType;
        end
    end
end
