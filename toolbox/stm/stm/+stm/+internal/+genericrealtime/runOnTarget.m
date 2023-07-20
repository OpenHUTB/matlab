function out=runOnTarget(simInput,runID,simWatcher,saveRunTo,inputSignalGroupRunFile,moveRun)








    stm.internal.genericrealtime.FollowProgress.progress(' === begin: runOnTarget() ===','clock',clock);
    endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('=== end: runOnTarget() ==='));




    simMode='';
    runcfg=stm.internal.RunTestConfiguration(simMode);


    out.RunID=runID;
    out.messages={};
    out.errorOrLog={};
    out.SimulationModeUsed=simMode;
    out.SimulationFailed=false;
    out.SimulationAsserted=false;
    out.IsIncomplete=false;


    warnReporter=stm.internal.genericrealtime.RTWarningDetector();











    executionContext=stm.internal.genericrealtime.ExecutionContext();


    executionContext.initializeInputData(...
    out,simInput,simWatcher,runcfg,...
    saveRunTo,inputSignalGroupRunFile);


    executionContext.preRunIterationHandling();

    executionContext.defaultSettings=stm.internal.genericrealtime.SettingsToRestore();
    if executionContext.realtimeWorkflow<=2
        cleanupSettings=onCleanup(@()(executionContext.defaultSettings.restoreSettings()));
    end

    try


        sltest_iterationName=simInput.IterationName;
        assignin('base','sltest_iterationName',sltest_iterationName);
        removeFromBase='clear(''sltest_iterationName'')';
        oc2=onCleanup(@()evalin('base',removeFromBase));

        executionContext.runPreloadCallback();



        if executionContext.realtimeWorkflow==1
            executionContext.applicationPath=executionContext.simInput.TargetApplication;
            [~,executionContext.applicationToRun,~]=fileparts(executionContext.applicationPath);
            stm.internal.genericrealtime.FollowProgress.progress(['Determined applicationToRun: ',executionContext.applicationToRun]);
        end


        if executionContext.realtimeWorkflow==0
            modelCleanup=onCleanup(@()cleanupModelSettings(simWatcher));
            executionContext.loadAndBuildModelAndHarness();
        end





        simWatcher.isFirstIteration=false;

        executionContext.connectToTarget();

        if executionContext.realtimeWorkflow==1||...
            executionContext.realtimeWorkflow==2
            executionContext.setupInputData();

            cleanIt=onCleanup(@()cleanupIterationSettings(simWatcher));
        end

        if executionContext.realtimeWorkflow<2

            executionContext.loadApplicationToTarget();
        elseif(executionContext.realtimeWorkflow==2)


            executionContext.loadApplicationFromTarget();
        end

        executionContext.setupLogging();

        executionContext.overrideParameters();
        executionContext.overrideSLDVParameters();
        if executionContext.realtimeWorkflow<=2
            executionContext.overrideStopTime();
        end

        executionContext.runPreStartRealTimeApplicationCallback();

        executionContext.runRealTimeApplication();

        executionContext.processData(moveRun);

        if executionContext.realtimeWorkflow<=2
            executionContext.getParamValuesForAssessments();
            executionContext.getTestCaseMetaData();
            executionContext.retrieveExecutionInfo();
        end

        executionContext.runCleanupScript();


        defaultSettings=executionContext.defaultSettings;
        out=executionContext.out;



        defaultSettings.restoreStopTime();


        warnings=warnReporter.DetectedWarnings;
        for i=1:numel(warnings)
            out.messages{end+1}=warnings(i).message;
            out.errorOrLog{end+1}=false;
        end


        if(~isempty(executionContext.execMessages))
            out.messages=[out.messages,executionContext.execMessages.messages];
            out.errorOrLog=[out.errorOrLog,executionContext.execMessages.errorOrLog];
        end
    catch ME
        out=executionContext.out;
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(ME);
        out.messages=[out.messages,tempErrors];
        out.errorOrLog=[out.errorOrLog,tempErrorOrLog];
        tg=slrealtime;
        if tg.isConnected
            executionContext.retrieveExecutionInfo();
            if(~isempty(executionContext.execMessages))
                out.messages=[out.messages,executionContext.execMessages.messages];
                out.errorOrLog=[out.errorOrLog,executionContext.execMessages.errorOrLog];
            end
        end
    end
end

function cleanupModelSettings(simWatcher)
    stm.internal.genericrealtime.FollowProgress.progress('begin: cleanupModelSettings()');
    endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: cleanupModelSettings()'));
    stm.internal.genericrealtime.revertModelSettings(simWatcher);
end

function cleanupIterationSettings(simWatcher)
    stm.internal.genericrealtime.FollowProgress.progress('begin: cleanupIterationSettings()');
    endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: cleanupIterationSettings()'));
    simWatcher.revertIterationSettings();
end
