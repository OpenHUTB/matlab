function verifyTaskToEventSourceAssignment(tskMgr)




    rawData=get_param(tskMgr,'AllTaskData');
    dataObj=soc.internal.TaskManagerData(rawData);
    err=soc.internal.taskmanager.verifyTaskToEventSourceAssignmentCore(...
    dataObj,tskMgr);
    if~isempty(err)
        error(message(err.ID,err.Args{:}));
    end
end
