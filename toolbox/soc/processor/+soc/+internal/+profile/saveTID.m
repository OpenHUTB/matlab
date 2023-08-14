function out=saveTID(modelName,offset,taskName,taskID,taskPriority,taskCoreSelection,taskCoreNum)
    buildDir=RTW.getBuildDir(modelName);
    if~isequal(exist(buildDir.BuildDirectory,'dir'),7)
        return;
    end
    if offset<2
        taskVec=[];
    else
        dataMat=load(fullfile(buildDir.BuildDirectory,'tasks.mat'));
        taskVec=dataMat.taskVec;
    end
    ctd=get_param(modelName,'CoderTargetData');
    if isfield(ctd,'RTOS')&&~isequal(ctd.RTOS,'Baremetal')
        BRPr=eval(ctd.RTOSBaseRateTaskPriority);
    else
        BRPr=40;
    end
    if isequal(get_param(modelName,'PositivePriorityOrder'),'off')
        taskPriority=BRPr+(BRPr-taskPriority);
    end
    if isequal(taskCoreSelection,2)||isequal(taskCoreSelection,'Specified core')
        tmp=taskCoreNum;
        if isnumeric(tmp)
            affinity=uint32(tmp);
        elseif ischar(tmp)
            affinity=uint32(eval(tmp));
        else
            assert(false,['coreNum for ''',blk,''' must be numeric or an evaluatable string']);
        end
        t=struct('name',taskName,'tid',taskID,'priority',taskPriority,'affinity',affinity);
    else
        t=struct('name',taskName,'tid',taskID,'priority',taskPriority,'affinity',uint32([]));
    end
    if isempty(taskVec)
        taskVec=t;
    else
        taskVec(end+1)=t;
    end
    save(fullfile(buildDir.BuildDirectory,'tasks.mat'),'taskVec');
    out=numel(taskVec);
end