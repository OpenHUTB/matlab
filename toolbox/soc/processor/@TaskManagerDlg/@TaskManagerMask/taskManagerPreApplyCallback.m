function[status,errMsg]=taskManagerPreApplyCallback(hMask,hDlg)










    mdlName=get_param(bdroot(hMask.BlockHandle),'Name');
    env=loc_GetEnvironment(mdlName);

    soc.internal.taskmanager.validateTaskParameters(hMask.taskName,...
    hMask.taskType,hMask.taskPeriod,hMask.coreNum,hMask.taskPriority,...
    (0:env.NumCores-1),env.TaskPriorities);
    soc.internal.taskmanager.validateTaskDurationData(hMask.taskDurationData);

    if~isempty(hMask.taskEditData)&&~isequal(hMask.taskEditData,'[]')&&...
        ~isequal(hMask.taskEditData,'{}')


        hMask.Block.TaskEditData=hMask.taskEditData;

        hMask.taskEditData='{}';
    end
    val={'off','on'};
    fh=@soc.internal.TaskManagerData;



    if~isequal(fh(hMask.Block.AllTaskData),fh(hMask.allTaskData))
        hMask.Block.AllTaskData=hMask.allTaskData;
    end
    hMask.Block.EnableTaskSimulation=val{hMask.enableTaskSimulation+1};
    hMask.Block.UseScheduleEditor=val{hMask.useScheduleEditor+1};
    hMask.Block.StreamToSDI=val{hMask.streamToSDI+1};
    hMask.Block.WriteToFile=val{hMask.writeToFile+1};
    hMask.Block.OverwriteFile=val{hMask.overwriteFile+1};




    [status,errMsg]=hMask.preApplyCallback(hDlg);
end


function env=loc_GetEnvironment(mdlName)
    env=codertarget.targethardware.getEnvironment(mdlName);
    if isempty(env)
        env=struct(...
        'NumCores',1,...
        'MaxNumTasks',99,...
        'MaxNumTimers',99,...
        'TaskPriorities',int16(1:99),...
        'TaskPriorityDescending',1,...
        'KernelLatency',0,...
        'TaskContextSaveTime',0,...
        'TaskContextRestoreTime',0,...
        'ModeChangeTime',0...
        );
    end
end
