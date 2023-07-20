function autoassignTaskToEventSource(blk)




    import soc.internal.taskmanager.*

    assignType=DAStudio.message('codertarget:utils:AutoAssigned');
    rawData=get_param(blk,'AllTaskData');
    dm=soc.internal.TaskManagerData(rawData);
    tskNames=getEventDrivenTaskNames(blk);
    for j=1:numel(tskNames)
        thisTask=tskNames{j};
        [evtSrc,evtType]=getEventSourceBlockForTask(blk,thisTask);
        if isequal(evtType,'Event Source'),continue;end
        if isempty(evtSrc),continue;end
        evtSrcName=get_param(evtSrc,'Name');
        dm.updateTask(thisTask,'taskEventSource',evtSrcName);
        dm.updateTask(thisTask,'taskEventSourceType',evtType);
        dm.updateTask(thisTask,'taskEventSourceAssignmentType',assignType);
    end
    newData=dm.getData;
    set_param(blk,'AllTaskData',newData);
end
