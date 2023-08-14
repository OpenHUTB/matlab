function profiling_callback(model,lGlobalRegistry,buildInfoInstr)




    storeDataFunctionName='slrealtimeUploadEvent';
    profilingUtilitiesFile='slrealtime_code_profiling_utility_functions';
    singleThreadTiming=false;


    slrtTimer=slrealtime.internal.ProfileTimer;

    if strcmp(get_param(model,'SystemTargetFile'),'slrtlinux_arm64.tlc')
        slrtTimer.setSourceFile('');
    end
    slrtTimer.setReadTimerExpression('slrealtimeAddEvent(sectionId)')

    lGlobalRegistry.ProfilingTimer=slrtTimer;
    lGlobalRegistry.TargetCollectDataFcnName=storeDataFunctionName;

    lGlobalRegistry=populate_task_name(model,lGlobalRegistry);


    targetLang=get_param(model,'TargetLang');
    if strcmp(targetLang,'C')
        srcExt='.c';
        headerExt='.h';
    else
        srcExt='.cpp';
        headerExt='.h';
    end


    lCodeDir=fullfile(buildInfoInstr.Settings.LocalAnchorDir,...
    buildInfoInstr.ComponentBuildFolder);
    lSourceFile=fullfile(lCodeDir,[profilingUtilitiesFile,srcExt]);
    lHeaderFile=fullfile(lCodeDir,[profilingUtilitiesFile,headerExt]);
    lGlobalRegistry.SourceFileTargetInterface=lSourceFile;
    lGlobalRegistry.HeaderFileTargetInterface=lHeaderFile;
    lGlobalRegistry.SingleThreadTiming=singleThreadTiming;

end

function lGlobalRegistry=populate_task_name(model,lGlobalRegistry)
    LASTIRQ=132;

    bDirInfo=RTW.getBuildDir(bdroot);
    buildDir=bDirInfo.BuildDirectory;
    lTaskRegistry=...
    coder.profile.TimeProbeComponentRegistry(...
    '',...
    '',...
    get_param(model,'TargetWordSize'),...
    buildDir,...
    []);
    lGlobalRegistry.addRegistries({lTaskRegistry});

    taskinfo=get_task_info(model);

    save('taskinfo.mat','taskinfo');

    for i=1:LASTIRQ
        lTaskRegistry.requestIdentifierForTask(taskinfo(i).taskName,...
        taskinfo(i),model);
    end

end


function taskInfo=get_task_info(model)
    TASKS=struct('MAXTHREADID',64,'FIRSTIRQ',101,'LASTIRQ',132);
    XPCTASK_MAX_PRIO=254;


    for i=TASKS.LASTIRQ:-1:1
        taskInfo(i).samplePeriod=inf;
        taskInfo(i).sampleOffset=0;
        taskInfo(i).taskPrio=0;
        taskInfo(i).entryPoints={};
    end

    for i=TASKS.LASTIRQ:-1:TASKS.FIRSTIRQ+1
        taskInfo(i).taskName=['IRQ',num2str(i-TASKS.FIRSTIRQ)];
        taskInfo(i).taskPrio=XPCTASK_MAX_PRIO+1;
    end

    taskInfo(TASKS.FIRSTIRQ).taskName='Timer';
    taskInfo(TASKS.FIRSTIRQ).taskPrio=XPCTASK_MAX_PRIO+1;


    for i=TASKS.MAXTHREADID+1:TASKS.FIRSTIRQ-1
        taskInfo(i).taskName=['IRQ',num2str(i-TASKS.MAXTHREADID-1),'Thread'];
        taskInfo(i).taskPrio=XPCTASK_MAX_PRIO+1;
    end

    for i=1:TASKS.MAXTHREADID
        taskInfo(i).taskName=['Thread',num2str(i)];
    end

    if isempty(model)
        return;
    end


    clear slrealtime_task_info
    [taskif,n]=slrealtime_task_info();
    taskInfo(1:n)=taskif;
end
