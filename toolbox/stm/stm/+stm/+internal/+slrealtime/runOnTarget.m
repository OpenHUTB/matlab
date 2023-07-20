function out=runOnTarget(simInput,runID,simWatcher,saveRunTo,inputSignalGroupRunFile)







    simMode='';
    runcfg=stm.internal.RunTestConfiguration(simMode);


    out.RunID=runID;
    out.messages={};
    out.errorOrLog={};
    out.SimulationModeUsed=simMode;
    out.SimulationFailed=false;
    out.SimulationAsserted=false;
    out.IsIncomplete=false;


    warnReporter=stm.internal.slrealtime.RTWarningDetector();









    realtimeWorkflow=simInput.LoadApplicationFrom;
    bUsingExternalInputs=~isempty(simInput.InputFilePath);


    if(~isempty(simInput.TestIteration.TestParameter.SigBuilderGroupName))
        TestParameter=simInput.TestIteration.TestParameter;
        simInput.SigBuilderGroupName=TestParameter.SigBuilderGroupName;
        simInput.IsSigBuilderUsed=true;
    end


    if~isempty(simInput.TestIteration.TestParameter.TestSequenceScenario)
        TestParameter=simInput.TestIteration.TestParameter;
        simInput.TestSequenceScenario=TestParameter.TestSequenceScenario;
    end

    if simWatcher.isFirstIteration&&realtimeWorkflow~=0&&...
        (~isempty(simInput.TestSequenceBlock)||~(isempty(simInput.TestSequenceScenario)))
        error(message('stm:realtime:TestSequenceScenarioNotSupported'));
    end




    if~simWatcher.isFirstIteration...
        &&~simInput.IsSigBuilderUsed...
        &&isempty(simInput.TestIteration.SignalBuilderGroups)...
        &&isempty(simInput.TestIteration.TestParameter.LoggedSignalSetId)

        if bUsingExternalInputs

            if realtimeWorkflow==0


                simInput.TargetApplication=simWatcher.modelToRun;
                realtimeWorkflow=1;
            end
        else
            realtimeWorkflow=2;
        end
    end

    defaultSettings=stm.internal.slrealtime.SettingsToRestore();
    cleanupSettings=onCleanup(@()(defaultSettings.restoreSettings()));

    try


        sltest_iterationName=simInput.IterationName;
        assignin('base','sltest_iterationName',sltest_iterationName);
        removeFromBase='clear(''sltest_iterationName'')';
        oc2=onCleanup(@()evalin('base',removeFromBase));


        stm.internal.slrealtime.FollowProgress.progress('-- Start: Run preLoad callback --');
        stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:RunningPreLoadCallback')));
        me=runcfg.runPreload(simInput);
        if~isempty(me)
            out.messages=[out.messages,runcfg.out.messages];
            out.errorOrLog=[out.errorOrLog,runcfg.out.errorOrLog];
            rethrow(me);
        end
        stm.internal.slrealtime.FollowProgress.progress('-- End: Run preLoad callback --');



        applicationPath='';
        applicationToRun='';
        if realtimeWorkflow==1
            applicationPath=simInput.TargetApplication;
            [~,applicationToRun,~]=fileparts(applicationPath);
        end


        isStopTimeOverridenDuringBuild=false;

        sldvParameters=[];
        if realtimeWorkflow==0
            modelUtil=[];
            try
                stm.internal.slrealtime.FollowProgress.progress('-- Start: Load Simulink model --');
                stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:LoadingModel')));


                modelCleanup=onCleanup(@()stm.internal.slrealtime.revertModelSettings(simWatcher));

                applicationToRun=stm.internal.slrealtime.loadModel(simInput.Model,simInput.SubSystem,simWatcher);
                applicationPath=applicationToRun;
                stm.internal.slrealtime.FollowProgress.progress('-- End: Load Simulink model --');


                stm.internal.slrealtime.FollowProgress.progress('-- Start: Run postLoad callback --');
                stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:RunningPostLoadCallback')));
                me=runcfg.runPostload(simInput,simWatcher);
                if~isempty(me)
                    out.messages=[out.messages,runcfg.out.messages];
                    out.errorOrLog=[out.errorOrLog,runcfg.out.errorOrLog];
                    rethrow(me);
                end
                stm.internal.slrealtime.FollowProgress.progress('-- End: Run postLoad callback --');



                stm.internal.slrealtime.FollowProgress.progress('-- Start: Override Simulink model properties--');
                outOverrideModelProp=stm.internal.slrealtime.overrideModelProperties(simInput,simWatcher);
                out.messages=[out.messages,outOverrideModelProp.messages];
                out.errorOrLog=[out.errorOrLog,outOverrideModelProp.errorOrLog];
                if(~isempty(outOverrideModelProp.IterationModelParameters))
                    out.IterationModelParameters=outOverrideModelProp.IterationModelParameters;
                end
                if(~isempty(outOverrideModelProp.IterationSignalBuilderGroupsParameters))
                    out.IterationSignalBuilderGroupsParameters=outOverrideModelProp.IterationSignalBuilderGroupsParameters;
                end


                msgList=stm.internal.slrealtime.configureSignalsForStreaming(applicationToRun,simInput,simWatcher);
                for k=1:length(msgList)
                    out.messages{end+1}=msgList{k};
                    out.errorOrLog{end+1}=true;
                end


                if(simInput.IsSigBuilderUsed||bUsingExternalInputs||simInput.IncludeExternalInputs||simInput.StopSimAtLastTimePoint)
                    modelUtil=stm.internal.util.SimulinkModel(applicationToRun,simInput.SubSystem);

                    [simWatcher.cleanupIteration.LoadExternalInput,...
                    simWatcher.cleanupIteration.ExternalInput,...
                    ~,...
                    ~,...
                    simWatcher.cleanupIteration.VarsLoaded,...
                    simWatcher.cleanupIteration.StopTime,...
                    sldvParameters,...
                    warnMessage,...
                    logOrError,out.ExternalInputRunData,out.SigBuilderInfo]=modelUtil.loadInputs(simInput,'',inputSignalGroupRunFile);

                    if~isempty(logOrError)&&~isempty(warnMessage)
                        out.messages=[out.messages,warnMessage];
                        out.errorOrLog=[out.errorOrLog,logOrError];
                    end



                    isStopTimeOverridenDuringBuild=~isempty(simWatcher.cleanupIteration.StopTime);
                    if~isempty(modelUtil)
                        modelUtil.delete();
                    end
                end

                stm.internal.slrealtime.FollowProgress.progress('-- End: Override Simulink model properties --');


                stm.internal.slrealtime.FollowProgress.progress('-- Start: Build Simulink model --');
                stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:BuildingModel')));
                stm.internal.slrealtime.buildModel(applicationToRun);
                stm.internal.slrealtime.FollowProgress.progress('-- End: Build Simulink model --');

            catch ME
                if~isempty(modelUtil)
                    modelUtil.delete();
                end
                rethrow(ME);
            end
        end







        simWatcher.isFirstIteration=false;


        stm.internal.slrealtime.FollowProgress.progress('-- Start: Connect to target --');
        stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:ConnectingToTarget')));
        defaultTarget=stm.internal.slrealtime.connectToTarget(simInput.TargetComputer);
        targetName=simInput.TargetComputer;
        if isempty(targetName)
            targetName=defaultTarget;
        end


        if~strcmpi(defaultTarget,simInput.TargetComputer)
            defaultSettings.defaultTarget=defaultTarget;
        end
        stm.internal.slrealtime.FollowProgress.progress('-- End: Connect to target --');



        isStopTimeOverridenByInputs=false;
        if realtimeWorkflow>=1&&~isempty(simInput.InputFilePath)
            stm.internal.slrealtime.FollowProgress.progress('-- Start: Load input data --');

            [~,~,~,~,...
            simWatcher.cleanupIteration.VarsLoaded,...
            ~,...
            sldvParameters,...
            warnMessage,...
            logOrError,out.ExternalInputRunData,~,...
            rtInfo]=stm.internal.util.loadInputData([],simInput,'','');

            if~isempty(logOrError)&&~isempty(warnMessage)
                out.messages=[out.messages,warnMessage];
                out.errorOrLog=[out.errorOrLog,logOrError];
            end

            if(~isempty(rtInfo.externalInput))

                dstDir=tempname;
                if~exist(dstDir,'dir')
                    mkdir(dstDir);
                end
                cleanDir=onCleanup(@()rmdir(dstDir,'S'));

                if realtimeWorkflow==2


                    tg=slrealtime;
                    if(isempty(tg.getLastApplication))
                        error(message('stm:realtime:NoApplicationLoadedOnTarget'));
                    end
                    applicationPath=tg.getApplicationFile(tg.getLastApplication);
                    [~,applicationToRun,~]=fileparts(applicationPath);
                    if(strcmpi(applicationToRun,''))
                        error(message('stm:realtime:NoApplicationLoadedOnTarget'));
                    end


                    realtimeWorkflow=1;
                else


                    [appDir,applicationToRun,~]=fileparts(applicationPath);
                    applicationPath=fullfile(appDir,[applicationToRun,'.mldatx']);
                end


                [success,msg,~]=copyfile(applicationPath,dstDir);

                if(success)



                    currentDir=pwd;
                    cd(dstDir);
                    try
                        app_object=slrealtime.Application(applicationToRun);
                        app_object.updateRootLevelInportDataWithMapping(char(rtInfo.externalInput));
                    catch me

                        cd(currentDir);
                        rethrow(me);
                    end

                    cd(currentDir);

                    applicationPath=fullfile(dstDir,[applicationToRun,'.mldatx']);
                else

                    out.messages{end+1}=msg;
                    out.errorOrLog{end+1}=true;
                    return;
                end
            end

            if~isempty(rtInfo.stopTime)
                isStopTimeOverridenByInputs=true;
            end


            cleanIt=onCleanup(@()simWatcher.revertIterationSettings());

            stm.internal.slrealtime.FollowProgress.progress('-- End: Load input data --');
        end




        if realtimeWorkflow<2

            stm.internal.slrealtime.FollowProgress.progress('-- Start: Load application on target --');
            stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:LoadingApplication')));
            defaultSettings.application=applicationToRun;



            evalc('stm.internal.slrealtime.loadMldatx(applicationPath)');
            stm.internal.slrealtime.FollowProgress.progress('-- End: Load application on target --');
        else


            stm.internal.slrealtime.FollowProgress.progress('-- Start: Load application on target --');
            [~,applicationToRun]=evalc('stm.internal.slrealtime.loadMldatxFromTarget()');
            stm.internal.slrealtime.FollowProgress.progress('-- End: Load application on target --');
        end



        Simulink.HMI.DatabaseStreaming.removeModelFromActiveSimList(applicationToRun);





        currentParameterSetId=-1;
        if(isfield(simInput,'ParameterSetId'))
            if(~isempty(simInput.ParameterSetId))
                currentParameterSetId=simInput.ParameterSetId;
            end
            if(~isempty(simInput.TestIteration.TestParameter.ParameterSetId))
                currentParameterSetId=simInput.TestIteration.TestParameter.ParameterSetId;
            end
        end

        if(currentParameterSetId>0)



            tmpOverrides=stm.internal.getParameterOverrideDetails(currentParameterSetId);
            simInput.OverridesStruct=tmpOverrides;
            if(isfield(tmpOverrides,'Errors'))
                if~isempty(tmpOverrides.Errors)
                    for k=1:length(tmpOverrides.Errors)
                        out.messages{end+1}=tmpOverrides.Errors{k};
                        out.errorOrLog{end+1}=true;
                    end
                    return;
                end
            end
        end

        variableParam=[];

        if(~isempty(simInput.TestIteration)&&~isempty(simInput.TestIteration.VariableParameter))
            variableParam=simInput.TestIteration.VariableParameter;
            len=length(variableParam);

            overridesCache=cell(3,len);
            for i=1:len
                overridesCache{1,i}=0;
                overridesCache{2,i}=-1;
                overridesCache{3,i}=char('');
            end
            for k=1:len

                if(strcmp(variableParam(k).Source,'base workspace')||strcmp(variableParam(k).Source,'model workspace'))
                    variableParam(k).SourceType=variableParam(k).Source;
                else
                    variableParam(k).SourceType='real-time application';
                end
                variableParam(k).RuntimeValue=variableParam(k).Value;
                if(ischar(variableParam(k).Value))
                    variableParam(k).IsDerived=false;
                else
                    variableParam(k).IsDerived=true;
                end
                variableParam(k).Value=variableParam(k).Value;
                variableParam(k).IsChecked=true;

                overridesCache{1,k}=variableParam(k).RuntimeValue;
                overridesCache{2,k}=variableParam(k).Id;
                [~,overridesCache{3,k}]=stm.internal.util.getDisplayValue(variableParam(k).Value);
            end

            out.IterationVariableParameters=overridesCache;
        end
        overrideParam=[];
        if~isempty(simInput.OverridesStruct)
            overrideParam=simInput.OverridesStruct.ParameterOverrides;


            len=length(overrideParam);

            overridesCache=cell(3,len);
            for i=1:len
                overridesCache{1,i}=0;
                overridesCache{2,i}=-1;
                overridesCache{3,i}=char('');
            end
            for k=1:len
                overridesCache{1,k}=overrideParam(k).Value;
                overridesCache{2,k}=overrideParam(k).NamedParamId;
                [~,overridesCache{3,k}]=stm.internal.util.getDisplayValue(overrideParam(k).Value);
            end
            out.OverridesCache=overridesCache;
        end


        scenarioParam=[];

        if~isempty(simInput.TestSequenceBlock)||~isempty(simInput.TestSequenceScenario)
            blockpath=simInput.TestSequenceBlock;
            if isempty(blockpath)
                error(message('stm:general:NoTestSequenceBlockSpecified'));
            end


            find_system(blockpath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2);
            paramName=sltest.testsequence.getProperty(blockpath,'ScenarioParameter');
            if isempty(paramName)
                error(message('stm:general:TestSequenceNoScenario',blockPath));
            end
            overrideTSScenario=simInput.TestSequenceScenario;
            if isempty(simInput.TestSequenceScenario)

                if sltest.testsequence.getScenarioControlSource(blockpath)==sltest.testsequence.ScenarioControlSource.Block
                    overrideTSScenario=sltest.testsequence.getActiveScenario(blockpath);
                end
            else
                [tf,activeIndex]=ismember(simInput.TestSequenceScenario,sltest.testsequence.internal.getAllScenarios(blockpath));
                if~tf
                    error(message('stm:general:InvalidTestSequenceScenario',simInput.TestSequenceScenario,blockpath));
                end

                if sltest.testsequence.getScenarioControlSource(blockpath)==sltest.testsequence.ScenarioControlSource.Block
                    scenarioParam=struct('Name',paramName,'Source',simInput.TestSequenceBlock,'Value',activeIndex);
                else
                    scenarioParam=struct('Name',paramName,'Source','','Value',activeIndex);
                end

            end
            out.TestSequenceInfo=struct('TestSequenceBlock','','TestSequenceScenario','');
            out.TestSequenceInfo.TestSequenceBlock=blockpath;
            out.TestSequenceInfo.TestSequenceScenario=overrideTSScenario;
        end


        if(~isempty(overrideParam)||~isempty(variableParam))||~isempty(scenarioParam)
            stm.internal.slrealtime.FollowProgress.progress('-- Start: Override parameters --');
            stm.internal.slrealtime.overrideParameters(overrideParam,variableParam,scenarioParam,targetName,applicationToRun);
            stm.internal.slrealtime.FollowProgress.progress('-- End: Override parameters --');
        end



        if~isempty(sldvParameters)
            stm.internal.slrealtime.FollowProgress.progress('-- Start: Override SLDV parameters --');
            sldvParamSet=repmat(struct('Name','','Source','','Value',''),numel(sldvParameters),1);
            for k=1:numel(sldvParameters)
                sldvParamSet(k).Name=sldvParameters(k).name;
                sldvParamSet(k).Source='';
                sldvParamSet(k).Value=sldvParameters(k).value;
            end
            try
                sldvparametersToRestore=stm.internal.slrealtime.overrideParameters(sldvParamSet,[],[],targetName,applicationToRun);
            catch
                error(message('stm:realtime:IncompatibleSLDVParameter'));
            end
            stm.internal.slrealtime.FollowProgress.progress('-- End: Override SLDV parameters --');
        end





        if(~isStopTimeOverridenByInputs&&simInput.IsStopTimeEnabled&&~isStopTimeOverridenDuringBuild)
            stm.internal.slrealtime.FollowProgress.progress('-- Start: Override Stop Time --');
            defaultSettings.stopTime=stm.internal.slrealtime.overrideStopTime(simInput.StopTime);
            stm.internal.slrealtime.FollowProgress.progress('-- End: Override Stop Time --');
        end


        if(isStopTimeOverridenByInputs)
            stm.internal.slrealtime.FollowProgress.progress('-- Start: Override Stop Time --');
            defaultSettings.stopTime=stm.internal.slrealtime.overrideStopTime(rtInfo.stopTime);
            stm.internal.slrealtime.FollowProgress.progress('-- End: Override Stop Time --');
        end



        if(~isempty(simInput.TestIteration.TestParameter.PreStartRealTimeApplicationScript))
            simInput.PreStartRealTimeApplicationScript=simInput.TestIteration.TestParameter.PreStartRealTimeApplicationScript;
        end
        if(~isempty(simInput.PreStartRealTimeApplicationScript))
            stm.internal.slrealtime.FollowProgress.progress('-- Start: Run pre-start realtime application callback --');
            stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:RunningPreStartCallback')));
            try
                stm.internal.MRT.share.evaluateScript('',...
                '','',simInput.PreStartRealTimeApplicationScript,...
                simInput.TestCaseId,'','','','','','','','','',...
                simInput.IterationName,runcfg.runningOnMRT);
            catch me
                scr=getString(message('stm:general:PreStartRealTimeApplicationCallback'));
                msg=getString(message('stm:general:ScriptError',scr));
                out.messages{end+1}=msg;
                out.errorOrLog{end+1}=true;
                out.messages{end+1}=me.message;
                out.errorOrLog{end+1}=true;
                rethrow(me);
            end
            stm.internal.slrealtime.FollowProgress.progress('-- End: Run pre-start realtime application callback --');
        end


        out.timeStampStart=datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');

        stm.internal.slrealtime.FollowProgress.progress('-- Start: Run application on target --');
        stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:RunningApplication','0%')));



        evalc('stm.internal.slrealtime.runApplicationOnTarget(targetName, applicationToRun, simInput.TestCaseId)');
        stm.internal.slrealtime.FollowProgress.progress('-- End: Run application on target --');

        out.timeStampStop=datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');


        stm.internal.slrealtime.FollowProgress.progress('-- Start: Process data from target --');
        stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:ProcessRealTimeData')));




        if isempty(saveRunTo)
            Simulink.sdi.internal.flushStreamingBackend();
            tg=slrealtime;
            streamedRunID=slrealtime.internal.sdi.getActiveRunId(applicationToRun,tg.TargetSettings.name);

            if(streamedRunID~=0)
                Simulink.sdi.internal.moveRunToApp(streamedRunID,'stm');
                out.RunID=streamedRunID;
            end
        end

        evalc('stm.internal.slrealtime.processRealTimeData(out.RunID, targetName, applicationToRun)');
        stm.internal.slrealtime.FollowProgress.progress('-- End: Process data from target --');



        try
            assessmentsFeature=slfeature('AssessmentRunInCustomCriteria');
        catch
            assessmentsFeature=false;
        end
        if assessmentsFeature
            assessmentsData=[];
            try
                assessmentsInfo=stm.internal.getAssessmentsInfo(stm.internal.getAssessmentsID(simInput.TestCaseId));
                assessmentsEvaluator=sltest.assessments.internal.AssessmentsEvaluator(assessmentsInfo);
                if assessmentsEvaluator.hasAssessments()
                    paramSyms=assessmentsEvaluator.parseSymbols({'Variable','Parameter'},1,'',struct());
                    if(~isempty(paramSyms))


                        assessmentsData.parameterValues=structfun(@(x)struct('value',[],'info','','error',sltest.assessments.internal.AssessmentsException(message('sltest:assessments:ParameterNotSupportedInRealTimeTestCase',x.value))),paramSyms,'UniformOutput',false);
                    end
                end
            catch me
                assessmentsData=me;
            end
            out.assessmentsData=assessmentsData;
        end





        [~,out]=evalc('stm.internal.slrealtime.getTestCaseMetaData(applicationToRun, out, simWatcher, realtimeWorkflow)');


        stm.internal.slrealtime.FollowProgress.progress('-- Start: Retrieve execution information --');
        ExecMessages=stm.internal.slrealtime.getExecutionInformation(targetName);
        stm.internal.slrealtime.FollowProgress.progress('-- End: Retrieve execution information --');



        stm.internal.slrealtime.FollowProgress.progress('-- Start: Run cleanup callback --');
        stm.internal.Spinner.updateTestCaseSpinnerLabel(simInput.TestCaseId,getString(message('stm:Execution:RunningCleanupCallback')));

        runcfg.out.RunID=out.RunID;
        runcfg.runCleanup(simInput,[],[]);
        stm.internal.slrealtime.FollowProgress.progress('-- End: Run cleanup callback --');




        defaultSettings.restoreStopTime();


        warnings=warnReporter.DetectedWarnings;
        for i=1:numel(warnings)
            out.messages{end+1}=warnings(i).message;
            out.errorOrLog{end+1}=false;
        end


        out.messages=[out.messages,ExecMessages.messages];
        out.errorOrLog=[out.errorOrLog,ExecMessages.errorOrLog];
    catch ME
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(ME);
        out.messages=[out.messages,tempErrors];
        out.errorOrLog=[out.errorOrLog,tempErrorOrLog];
    end
end
