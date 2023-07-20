function executionProfile=getData(model)





    model=convertStringsToChars(model);
    lTimerClass='codertarget.profile.Timer';
    profiler=codertarget.attributes.getAttribute(model,'Profiler');
    fcnName=profiler.GetDataFcn;

    fcn=str2func(fcnName);

    [sectionIds,timerValues,coreNum]=fcn(model);

    lCodeGenFolder=Simulink.fileGenControl('getConfig').CodeGenFolder;
    bDirInfo=RTW.getBuildDir(model);

    isRealTime=true;
    lTimer=feval(lTimerClass,model);


    buildDir=fullfile(lCodeGenFolder,...
    bDirInfo.ModelRefRelativeBuildDir);
    binfoMATFile=fullfile(buildDir,'tmwinternal','binfo.mat');
    loadConfigSet=true;
    lTargetType='NONE';
    infoStruct=coder.internal.infoMATFileMgr('loadPostBuild','binfo',...
    model,lTargetType,binfoMATFile,...
    loadConfigSet);

    cs=infoStruct.configSet;
    summaryOnly=false;
    if~isempty(cs)
        if~strcmp(get_param(cs,'CodeProfilingSaveOptions'),'AllData')
            summaryOnly=true;
        end
    end
    lCodeDir=bDirInfo.BuildDirectory;

    if isempty(coreNum)
        executionProfile=coder.profile.executionTimeAnalyze...
        (timerValues,sectionIds,...
        'isRealTime',isRealTime,...
        'codeFolder',lCodeDir,...
        'InstrumentedCodeFolder','instrumented',...
        'timerTicksPerSecond',lTimer.TicksPerSecond,...
        'componentName',model,...
        'summaryOnly',summaryOnly);
    else
        executionProfile=coder.profile.executionTimeAnalyze...
        (timerValues,sectionIds,...
        'coreNumbers',coreNum,...
        'isRealTime',isRealTime,...
        'codeFolder',lCodeDir,...
        'InstrumentedCodeFolder','instrumented',...
        'timerTicksPerSecond',lTimer.TicksPerSecond,...
        'componentName',model,...
        'summaryOnly',summaryOnly);
    end
    var=get_param(model,'CodeExecutionProfileVariable');
    assignin('base',var,executionProfile);
end
