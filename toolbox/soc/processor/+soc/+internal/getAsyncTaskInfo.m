function info=getAsyncTaskInfo(blkh)




    mdl=bdroot(blkh);
    mgrBlk=loc_getTaskManagerBlock(blkh);
    allTaskData=get_param(mgrBlk,'AllTaskData');
    dm=soc.internal.TaskManagerData(allTaskData,'evaluate',mdl);
    allTaskNames=dm.getTaskNames;
    info.taskNames={};
    info.taskPriorities=[];
    for idx=1:numel(allTaskNames)
        taskName=allTaskNames{idx};
        taskData=dm.getTask(taskName);
        if isequal(taskData.taskType,'Event-driven')
            info.taskNames{end+1}=...
            [taskData.taskName,'_trigger'];
            info.taskPriorities(numel(info.taskNames))=taskData.taskPriority;
        end
    end
end


function mgrBlk=loc_getTaskManagerBlock(startBlk)
    curBlk=startBlk;
    while isequal(get_param(curBlk,'Type'),'block')&&...
        ~isequal(get_param(curBlk,'MaskType'),'Task Manager')
        curBlk=get_param(curBlk,'Parent');
    end
    assert(isequal(get_param(curBlk,'Type'),'block'),'Task Manager not found');
    mgrBlk=curBlk;
end
