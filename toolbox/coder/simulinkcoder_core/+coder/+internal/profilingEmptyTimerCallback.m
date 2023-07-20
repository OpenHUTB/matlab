function profilingEmptyTimerCallback(model,lGlobalRegistry,buildInfoInstr)







    lTimer=[];
    storeDataFunctionName='';
    profilingUtilitiesFile=coder.profile.ExecTimeConfig.EmptyTimerSrcName;
    singleThreadTiming=false;

    lGlobalRegistry.ProfilingTimer=lTimer;
    lGlobalRegistry.TargetCollectDataFcnName=...
    storeDataFunctionName;


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

