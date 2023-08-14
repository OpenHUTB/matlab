classdef ExecutionContext<handle



















    properties
        target;
        out;
        simInput;
        simWatcher;
        runcfg;
        realtimeWorkflow;
        isStopTimeOverridenDuringBuild;
        isStopTimeOverridenByInputs;
        bUsingExternalInputs;
        applicationPath;
        applicationToRun;
        sldvParameters;
        rtInfo;
        targetName;
        defaultSettings;
        sldvparametersToRestore;
        execMessages;
        saveRunTo;
        inputSignalGroupRunFile;
        startWallClockTime;
        cleanDir;
    end
    methods
        function obj=ExecutionContext()
            obj.startWallClockTime=clock;
            obj.out=[];
            obj.simInput=[];
            obj.simWatcher=[];
            obj.runcfg=[];
            obj.realtimeWorkflow=0;
            obj.isStopTimeOverridenDuringBuild=false;
            obj.isStopTimeOverridenByInputs=false;
            obj.bUsingExternalInputs=false;
            obj.applicationPath='';
            obj.applicationToRun='';
            obj.sldvParameters=[];
            obj.rtInfo=[];
            obj.targetName='';
            obj.defaultSettings=[];
            obj.sldvparametersToRestore=[];
            obj.execMessages=[];
            obj.saveRunTo=[];
            obj.inputSignalGroupRunFile=[];
        end
        function initializeInputData(obj,out,simInput,simWatcher,runcfg,saveRunTo,inputSignalGroupRunFile)
            stm.internal.genericrealtime.FollowProgress.progress('begin: initializeInputData()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: initializeInputData()'));
            obj.out=out;
            obj.simInput=simInput;
            obj.simWatcher=simWatcher;
            obj.runcfg=runcfg;
            obj.realtimeWorkflow=simInput.LoadApplicationFrom;
            obj.bUsingExternalInputs=~isempty(simInput.InputFilePath);
            obj.saveRunTo=saveRunTo;
            obj.inputSignalGroupRunFile=inputSignalGroupRunFile;
        end


        function preRunIterationHandling(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: preRunIterationHandling()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: preRunIterationHandling()'));

            stm.internal.genericrealtime.FollowProgress.progress(['Iteration name: ',obj.simInput.IterationName]);


            if(~isempty(obj.simInput.TestIteration.TestParameter.SigBuilderGroupName))
                TestParameter=obj.simInput.TestIteration.TestParameter;
                obj.simInput.SigBuilderGroupName=TestParameter.SigBuilderGroupName;
                obj.simInput.IsSigBuilderUsed=true;
                stm.internal.genericrealtime.FollowProgress.progress('Signal builder is used in iteration');
            end


            if~isempty(obj.simInput.TestIteration.TestParameter.TestSequenceScenario)
                TestParameter=obj.simInput.TestIteration.TestParameter;
                obj.simInput.TestSequenceScenario=TestParameter.TestSequenceScenario;
                stm.internal.genericrealtime.FollowProgress.progress('Test sequence scenario is used in iteration');
            end

            if obj.simWatcher.isFirstIteration&&obj.realtimeWorkflow~=0&&...
                (~isempty(obj.simInput.TestSequenceBlock)||~(isempty(obj.simInput.TestSequenceScenario)))
                error(message('stm:realtime:TestSequenceScenarioNotSupported'));
            end




            if~obj.simWatcher.isFirstIteration...
                &&~obj.simInput.IsSigBuilderUsed...
                &&isempty(obj.simInput.TestIteration.SignalBuilderGroups)...
                &&isempty(obj.simInput.TestIteration.TestParameter.LoggedSignalSetId)

                stm.internal.genericrealtime.FollowProgress.progress('Not using Signal Builder nor LoggedSignalSet in iteration');
                if obj.bUsingExternalInputs
                    stm.internal.genericrealtime.FollowProgress.progress('Using external inputs in iteration');

                    if obj.realtimeWorkflow==0


                        obj.simInput.TargetApplication=obj.simWatcher.modelToRun;
                        obj.realtimeWorkflow=1;
                        stm.internal.genericrealtime.FollowProgress.progress('WORKFLOW: switching to worflow 1');
                    end
                else
                    obj.realtimeWorkflow=2;
                    stm.internal.genericrealtime.FollowProgress.progress('WORKFLOW: switching to worflow 2');
                end
            end
        end

        function runPreloadCallback(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: runPreloadCallback()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: runPreloadCallback()'));
            stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:RunningPreLoadCallback')));
            me=obj.runcfg.runPreload(obj.simInput);
            if~isempty(me)
                obj.out.messages=[obj.out.messages,obj.runcfg.out.messages];
                obj.out.errorOrLog=[obj.out.errorOrLog,obj.runcfg.out.errorOrLog];
                rethrow(me);
            end
        end

        function loadAndBuildModelAndHarness(obj)
            modelUtil=[];
            try
                stm.internal.genericrealtime.FollowProgress.progress('begin: loadAndBuildModelAndHarness()');
                endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: loadAndBuildModelAndHarness()'));
                stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:LoadingModel')));


                obj.applicationToRun=stm.internal.genericrealtime.loadModel(obj.simInput.Model,obj.simInput.SubSystem,obj.simWatcher);
                obj.applicationPath=obj.applicationToRun;
                stm.internal.genericrealtime.FollowProgress.progress(['Determined applicationToRun: ',obj.applicationToRun]);
                stm.internal.genericrealtime.FollowProgress.progress(['Determined applicationPath: ',obj.applicationPath]);


                stm.internal.genericrealtime.FollowProgress.progress('begin: calling postLoad callback');
                stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:RunningPostLoadCallback')));
                me=obj.runcfg.runPostload(obj.simInput,obj.simWatcher);
                if~isempty(me)
                    obj.out.messages=[obj.out.messages,obj.runcfg.out.messages];
                    obj.out.errorOrLog=[obj.out.errorOrLog,obj.runcfg.out.errorOrLog];
                    rethrow(me);
                end
                stm.internal.genericrealtime.FollowProgress.progress('end: calling postLoad callback');



                stm.internal.genericrealtime.FollowProgress.progress('begin: overriding Simulink model properties');
                outOverrideModelProp=stm.internal.genericrealtime.overrideModelProperties(obj.simInput,obj.simWatcher);
                obj.out.messages=[obj.out.messages,outOverrideModelProp.messages];
                obj.out.errorOrLog=[obj.out.errorOrLog,outOverrideModelProp.errorOrLog];
                if(~isempty(outOverrideModelProp.IterationModelParameters))
                    obj.out.IterationModelParameters=outOverrideModelProp.IterationModelParameters;
                end
                if(~isempty(outOverrideModelProp.IterationSignalBuilderGroupsParameters))
                    obj.out.IterationSignalBuilderGroupsParameters=outOverrideModelProp.IterationSignalBuilderGroupsParameters;
                end


                msgList=stm.internal.genericrealtime.configureSignalsForStreaming(obj.applicationToRun,obj.simInput,obj.simWatcher);
                for k=1:length(msgList)
                    obj.out.messages{end+1}=msgList{k};
                    obj.out.errorOrLog{end+1}=true;
                end


                if(obj.simInput.IsSigBuilderUsed||obj.bUsingExternalInputs||obj.simInput.IncludeExternalInputs||obj.simInput.StopSimAtLastTimePoint)
                    modelUtil=stm.internal.util.SimulinkModel(obj.applicationToRun,obj.simInput.SubSystem);

                    [obj.simWatcher.cleanupIteration.LoadExternalInput,...
                    obj.simWatcher.cleanupIteration.ExternalInput,...
                    ~,...
                    ~,...
                    obj.simWatcher.cleanupIteration.VarsLoaded,...
                    obj.simWatcher.cleanupIteration.StopTime,...
                    obj.sldvParameters,...
                    warnMessage,...
                    logOrError,obj.out.ExternalInputRunData,obj.out.SigBuilderInfo]=...
                    modelUtil.loadInputs(obj.simInput,'',obj.inputSignalGroupRunFile);

                    if~isempty(logOrError)&&~isempty(warnMessage)
                        obj.out.messages=[obj.out.messages,warnMessage];
                        obj.out.errorOrLog=[obj.out.errorOrLog,logOrError];
                    end



                    obj.isStopTimeOverridenDuringBuild=~isempty(obj.simWatcher.cleanupIteration.StopTime);
                    if~isempty(modelUtil)
                        modelUtil.delete();
                    end
                end

                stm.internal.genericrealtime.FollowProgress.progress('end: overriding Simulink model properties');


                stm.internal.genericrealtime.FollowProgress.progress('begin: build Simulink model');
                stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:BuildingModel')));
                stm.internal.genericrealtime.buildModel(obj.applicationToRun);
                stm.internal.genericrealtime.FollowProgress.progress('end: build Simulink model');

            catch ME
                if~isempty(modelUtil)
                    modelUtil.delete();
                end
                rethrow(ME);
            end
        end

        function connectToTarget(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: connectToTarget()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: connectToTarget()'));
            stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:ConnectingToTarget')));
            defaultTarget=stm.internal.genericrealtime.connectToTarget(obj.simInput.TargetComputer);
            obj.targetName=obj.simInput.TargetComputer;
            if isempty(obj.targetName)
                obj.targetName=defaultTarget;
            end


            if~strcmpi(defaultTarget,obj.simInput.TargetComputer)
                obj.defaultSettings.defaultTarget=defaultTarget;
            end
        end

        function setupInputData(obj)

            stm.internal.genericrealtime.FollowProgress.progress('begin: setupInputData()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: setupInputData()'));
            stm.internal.genericrealtime.FollowProgress.progress(['Input file path: ',obj.simInput.InputFilePath]);
            obj.isStopTimeOverridenByInputs=false;
            if obj.realtimeWorkflow>=1&&~isempty(obj.simInput.InputFilePath)
                stm.internal.genericrealtime.FollowProgress.progress('Calling stm.internal.util.loadInputData()');
                [~,~,~,~,...
                obj.simWatcher.cleanupIteration.VarsLoaded,...
                ~,...
                obj.sldvParameters,...
                warnMessage,...
                logOrError,obj.out.ExternalInputRunData,~,...
                obj.rtInfo]=stm.internal.util.loadInputData([],obj.simInput,'','');

                if~isempty(logOrError)&&~isempty(warnMessage)
                    obj.out.messages=[obj.out.messages,warnMessage];
                    obj.out.errorOrLog=[obj.out.errorOrLog,logOrError];
                end

                if(~isempty(obj.rtInfo.externalInput))

                    dstDir=tempname;
                    if~exist(dstDir,'dir')
                        mkdir(dstDir);
                    end
                    obj.cleanDir=onCleanup(@()rmdir(dstDir,'S'));

                    if obj.realtimeWorkflow==2


                        tg=slrealtime;
                        if(isempty(tg.getLastApplication))
                            error(message('stm:realtime:NoApplicationLoadedOnTarget'));
                        end
                        obj.applicationPath=tg.getApplicationFile(tg.getLastApplication);
                        [~,obj.applicationToRun,~]=fileparts(obj.applicationPath);
                        if(strcmpi(obj.applicationToRun,''))
                            error(message('stm:realtime:NoApplicationLoadedOnTarget'));
                        end
                        stm.internal.genericrealtime.FollowProgress.progress(['Determined applicationToRun: ',obj.applicationToRun]);


                        obj.realtimeWorkflow=1;
                    else


                        [appDir,obj.applicationToRun,~]=fileparts(obj.applicationPath);
                        obj.applicationPath=fullfile(appDir,[obj.applicationToRun,'.mldatx']);
                        stm.internal.genericrealtime.FollowProgress.progress(['Determined applicationToRun: ',obj.applicationToRun]);
                    end



                    stm.internal.genericrealtime.FollowProgress.progress('Copying RT application');
                    stm.internal.genericrealtime.FollowProgress.progress(['Source: ',obj.applicationPath]);
                    stm.internal.genericrealtime.FollowProgress.progress(['Destination: ',dstDir]);
                    [success,msg,~]=copyfile(obj.applicationPath,dstDir);

                    if(success)



                        currentDir=pwd;
                        cd(dstDir);
                        try
                            app_object=slrealtime.Application(obj.applicationToRun);
                            app_object.updateRootLevelInportDataWithMapping(char(obj.rtInfo.externalInput));
                        catch me

                            cd(currentDir);
                            rethrow(me);
                        end

                        cd(currentDir);

                        obj.applicationPath=fullfile(dstDir,[obj.applicationToRun,'.mldatx']);
                        stm.internal.genericrealtime.FollowProgress.progress(['Determined applicationPath: ',obj.applicationPath]);
                    else

                        obj.out.messages{end+1}=msg;
                        obj.out.errorOrLog{end+1}=true;
                        return;
                    end
                end

                if~isempty(obj.rtInfo.stopTime)
                    obj.isStopTimeOverridenByInputs=true;
                end

            end
        end


        function loadApplicationToTarget(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: loadApplicationToTarget()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: loadApplicationToTarget()'));
            stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:LoadingApplication')));
            obj.defaultSettings.application=obj.applicationToRun;
            stm.internal.genericrealtime.FollowProgress.progress(['Loading to target from applicationPath: ',obj.applicationPath]);



            evalc('stm.internal.genericrealtime.loadMldatx(obj.applicationPath)');
        end


        function loadApplicationFromTarget(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: loadApplicationFromTarget()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: loadApplicationFromTarget()'));
            [~,obj.applicationToRun]=evalc('stm.internal.genericrealtime.loadMldatxFromTarget()');
            stm.internal.genericrealtime.FollowProgress.progress(['Finished loading from target, applicationToRun: ',obj.applicationToRun]);
        end

        function setupLogging(obj)
            import stm.internal.genericrealtime.variables.*;
            stm.internal.genericrealtime.FollowProgress.progress('begin: setupLogging()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: setupLogging()'));

            Simulink.HMI.DatabaseStreaming.removeModelFromActiveSimList(obj.applicationToRun);
        end

        function overrideParameters(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: overrideParameters()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: overrideParameters()'));




            currentParameterSetId=-1;
            if(isfield(obj.simInput,'ParameterSetId'))
                if(~isempty(obj.simInput.ParameterSetId))
                    currentParameterSetId=obj.simInput.ParameterSetId;
                end
                if(~isempty(obj.simInput.TestIteration.TestParameter.ParameterSetId))
                    currentParameterSetId=obj.simInput.TestIteration.TestParameter.ParameterSetId;
                end
            end

            if(currentParameterSetId>0)



                tmpOverrides=stm.internal.getParameterOverrideDetails(currentParameterSetId);
                obj.simInput.OverridesStruct=tmpOverrides;
                if(isfield(tmpOverrides,'Errors'))
                    if~isempty(tmpOverrides.Errors)
                        for k=1:length(tmpOverrides.Errors)
                            obj.out.messages{end+1}=tmpOverrides.Errors{k};
                            obj.out.errorOrLog{end+1}=true;
                        end
                        return;
                    end
                end
            end

            variableParam=[];

            if(~isempty(obj.simInput.TestIteration)&&~isempty(obj.simInput.TestIteration.VariableParameter))
                variableParam=obj.simInput.TestIteration.VariableParameter;
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

                obj.out.IterationVariableParameters=overridesCache;
            end
            overrideParam=[];
            if~isempty(obj.simInput.OverridesStruct)
                overrideParam=obj.simInput.OverridesStruct.ParameterOverrides;


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
                obj.out.OverridesCache=overridesCache;
            end


            scenarioParam=[];

            if~isempty(obj.simInput.TestSequenceBlock)||~isempty(obj.simInput.TestSequenceScenario)
                blockpath=obj.simInput.TestSequenceBlock;
                if isempty(blockpath)
                    error(message('stm:general:NoTestSequenceBlockSpecified'));
                end


                find_system(blockpath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'SearchDepth',2);
                paramName=sltest.testsequence.getProperty(blockpath,'ScenarioParameter');
                if isempty(paramName)
                    error(message('stm:general:TestSequenceNoScenario',blockPath));
                end
                overrideTSScenario=obj.simInput.TestSequenceScenario;
                if isempty(obj.simInput.TestSequenceScenario)

                    if sltest.testsequence.getScenarioControlSource(blockpath)==sltest.testsequence.ScenarioControlSource.Block
                        overrideTSScenario=sltest.testsequence.getActiveScenario(blockpath);
                    end
                else
                    [tf,activeIndex]=ismember(obj.simInput.TestSequenceScenario,sltest.testsequence.internal.getAllScenarios(blockpath));
                    if~tf
                        error(message('stm:general:InvalidTestSequenceScenario',obj.simInput.TestSequenceScenario,blockpath));
                    end

                    if sltest.testsequence.getScenarioControlSource(blockpath)==sltest.testsequence.ScenarioControlSource.Block
                        scenarioParam=struct('Name',paramName,'Source',obj.simInput.TestSequenceBlock,'Value',activeIndex);
                    else
                        scenarioParam=struct('Name',paramName,'Source','','Value',activeIndex);
                    end

                end
                obj.out.TestSequenceInfo=struct('TestSequenceBlock','','TestSequenceScenario','');
                obj.out.TestSequenceInfo.TestSequenceBlock=blockpath;
                obj.out.TestSequenceInfo.TestSequenceScenario=overrideTSScenario;
            end


            if(~isempty(overrideParam)||~isempty(variableParam))||~isempty(scenarioParam)
                stm.internal.genericrealtime.FollowProgress.progress('Found parameters to override');
                stm.internal.genericrealtime.overrideParameters(obj,overrideParam,variableParam,scenarioParam);
            end
        end

        function overrideSLDVParameters(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: overrideSLDVParameters()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: overrideSLDVParameters()'));
            if~isempty(obj.sldvParameters)
                sldvParamSet=repmat(struct('Name','','Source','','Value',''),numel(obj.sldvParameters),1);
                for k=1:numel(obj.sldvParameters)
                    sldvParamSet(k).Name=obj.sldvParameters(k).name;
                    sldvParamSet(k).Source='';
                    sldvParamSet(k).Value=obj.sldvParameters(k).value;
                end
                try
                    obj.sldvparametersToRestore=stm.internal.genericrealtime.overrideParameters(obj,sldvParamSet,[],[]);
                catch ME
                    error(message('stm:realtime:IncompatibleSLDVParameter'));
                end
            end
        end


        function overrideStopTime(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: overrideStopTime()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: overrideStopTime()'));


            if(~obj.isStopTimeOverridenByInputs&&obj.simInput.IsStopTimeEnabled&&~obj.isStopTimeOverridenDuringBuild)
                obj.defaultSettings.stopTime=stm.internal.genericrealtime.overrideStopTime(obj.simInput.StopTime);
            end


            if(obj.isStopTimeOverridenByInputs)
                obj.defaultSettings.stopTime=stm.internal.genericrealtime.overrideStopTime(obj.rtInfo.stopTime);
            end
        end


        function runPreStartRealTimeApplicationCallback(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: runPreStartRealTimeApplicationCallback()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: runPreStartRealTimeApplicationCallback()'));
            if(~isempty(obj.simInput.TestIteration.TestParameter.PreStartRealTimeApplicationScript))
                obj.simInput.PreStartRealTimeApplicationScript=obj.simInput.TestIteration.TestParameter.PreStartRealTimeApplicationScript;
            end
            if(~isempty(obj.simInput.PreStartRealTimeApplicationScript))
                stm.internal.genericrealtime.FollowProgress.progress('-- begin: calling pre-start realtime application callback --');
                stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:RunningPreStartCallback')));
                try
                    stm.internal.MRT.share.evaluateScript('',...
                    '','',obj.simInput.PreStartRealTimeApplicationScript,...
                    obj.simInput.TestCaseId,'','','','','','','','','',...
                    obj.simInput.IterationName,obj.runcfg.runningOnMRT);
                catch me
                    scr=getString(message('stm:general:PreStartRealTimeApplicationCallback'));
                    msg=getString(message('stm:general:ScriptError',scr));
                    obj.out.messages{end+1}=msg;
                    obj.out.errorOrLog{end+1}=true;
                    obj.out.messages{end+1}=me.message;
                    obj.out.errorOrLog{end+1}=true;
                    rethrow(me);
                end
                stm.internal.genericrealtime.FollowProgress.progress('-- end: calling pre-start realtime application callback --');
            end
        end


        function runRealTimeApplication(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: runRealTimeApplication()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: runRealTimeApplication()'));
            obj.out.timeStampStart=datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
            stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:RunningApplication','0%')));



            evalc('stm.internal.genericrealtime.runApplicationOnTarget(obj.targetName, obj.applicationToRun, obj.simInput.TestCaseId)');
            obj.out.timeStampStop=datestr(now,'yyyy-mm-dd HH:MM:SS.FFF');
        end


        function processData(obj,moveRun)
            stm.internal.genericrealtime.FollowProgress.progress('begin: processData()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: processData()'));
            stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:ProcessRealTimeData')));




            if isempty(obj.saveRunTo)
                Simulink.sdi.internal.flushStreamingBackend();
                tg=slrealtime;
                if~isempty(tg.SDIRunId)&&Simulink.sdi.isValidRunID(tg.SDIRunId)
                    streamedRunID=slrealtime.internal.sdi.getActiveRunId(obj.applicationToRun,tg.TargetSettings.name);

                    if(streamedRunID~=0)
                        if moveRun
                            Simulink.sdi.internal.moveRunToApp(streamedRunID,'stm');
                        end
                        obj.out.RunID=streamedRunID;
                    end
                end
            end
            evalc('stm.internal.genericrealtime.processRealTimeData(obj.out.RunID, obj.targetName, obj.applicationToRun)');
            if(slfeature('STMOutputTriggering')>0)
                simOut=obj.createSimOut(obj.out.RunID);
                obj.simInput=stm.internal.trigger.filterSignalLoggingOnTriggers(obj.out.RunID,obj.simInput,simOut);
                obj.out.OutputTriggerInfo=obj.simInput.OutputTriggering;
            end
        end


        function getParamValuesForAssessments(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: getParamValuesForAssessments()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: getParamValuesForAssessments()'));
            try
                assessmentsFeature=slfeature('AssessmentRunInCustomCriteria');
            catch
                assessmentsFeature=false;
            end
            if assessmentsFeature
                assessmentsData=[];
                try
                    assessmentsInfo=stm.internal.getAssessmentsInfo(stm.internal.getAssessmentsID(obj.simInput.TestCaseId));
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
                obj.out.assessmentsData=assessmentsData;
            end
        end


        function getTestCaseMetaData(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: getTestCaseMetaData()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: getTestCaseMetaData()'));



            [~,obj.out]=evalc('stm.internal.genericrealtime.getTestCaseMetaData(obj.applicationToRun, obj.out, obj.simWatcher, obj.realtimeWorkflow)');
        end


        function retrieveExecutionInfo(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: retrieveExecutionInfo()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: retrieveExecutionInfo()'));
            obj.execMessages=stm.internal.genericrealtime.getExecutionInformation(obj.targetName);
        end

        function runCleanupScript(obj)
            stm.internal.genericrealtime.FollowProgress.progress('begin: runCleanupScript()');
            endProgress=onCleanup(@()stm.internal.genericrealtime.FollowProgress.progress('end: runCleanupScript()'));
            stm.internal.Spinner.updateTestCaseSpinnerLabel(obj.simInput.TestCaseId,getString(message('stm:Execution:RunningCleanupCallback')));

            obj.runcfg.out.RunID=obj.out.RunID;
            obj.runcfg.runCleanup(obj.simInput,[],[]);
        end

    end

    methods(Static)
        function simOut=createSimOut(runId)
            runObj=Simulink.sdi.getRun(runId);
            logsout=runObj.export();
            simOut=Simulink.SimulationOutput({});
            simOut.logsout=logsout;
        end
    end
end
