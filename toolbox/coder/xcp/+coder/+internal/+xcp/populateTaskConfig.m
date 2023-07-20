function err=populateTaskConfig(taskConfig,buildDir)





    err='';

    currentDir=pwd;
    restoreDir=onCleanup(@()cd(currentDir));
    cd(buildDir);
    assert(isfile('extmode_task_info.m'),...
    'cannot find extmode_task_info.m to populate TaskConfig');
    [taskInfos,numTasks,~]=extmode_task_info;
    clear restoreDir

    if numTasks>=2^16
        err='coder_xcp:host:TooManyTasksForXCP';
        return;
    end


    baseRatePeriod=-1;
    for i=1:numel(taskInfos)

        if(taskInfos(i).samplePeriod>0)
            baseRatePeriod=taskInfos(i).samplePeriod;
            break;
        end
    end

    if baseRatePeriod==-1
        err='coder_xcp:host:InvalidRatesForPackedMode';
        return;
    end
    taskConfig.BaseRatePeriod=baseRatePeriod;


    taskConfig.PeriodicTasks.clear();
    for i=1:numTasks
        if taskInfos(i).samplePeriod<=0

            continue;
        end
        rateInBaseRate=uint64(round(taskInfos(i).samplePeriod/baseRatePeriod));
        if abs(rateInBaseRate-(taskInfos(i).samplePeriod/baseRatePeriod))>sqrt(eps)
            err='coder_xcp:host:InvalidRatesForPackedMode';
            return;
        end
        taskConfig.createIntoPeriodicTasks(struct(...
        Period=rateInBaseRate,...
        Id=uint64(i-1)));
    end
end
