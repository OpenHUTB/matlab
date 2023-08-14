function out=runTestConfigurationMRT(simSettingFile,simIndex,bRunCallbacks,...
    workerSysPath,...
    saveRunTo,covSaveTo,inputDataSetsRunFile,inputSignalGroupRunFile)





    if(ischar(simIndex))
        simIndex=str2double(simIndex);
    end
    if(ischar(bRunCallbacks))
        bRunCallbacks=str2double(bRunCallbacks);
    end

    load(simSettingFile);
    if(simIndex==1)
        runCfgInput=simSettings.sim1;
    else
        runCfgInput=simSettings.sim2;
    end
    simInput=runCfgInput.simInput;

    runcfg=runTestConfigurationHelper(workerSysPath,...
    simInput,runCfgInput.runcfg,bRunCallbacks,...
    saveRunTo,covSaveTo,inputDataSetsRunFile,inputSignalGroupRunFile);
    out=runcfg.out;

    out.OutputSignalSetUsed=stm.internal.MRT.utility.getLoggedSignalSet(simInput);
end

function runcfg=runTestConfigurationHelper(workerSysPath,simInput,initRunCfg,bRunCallbacks,saveRunTo,covSaveTo,inputDataSetsRunFile,inputSignalGroupRunFile)




    warnState=warning('off','backtrace');
    oc=onCleanup(@()warning(warnState));

    runcfg=stm.internal.MRT.utility.RunTestConfiguration();
    runcfg.testSettings=initRunCfg.testSettings;
    runcfg.testIteration=initRunCfg.testIteration;
    runcfg.runningOnPCT=true;
    runcfg.runningOnMRT=true;
    runcfg.runCallbacks=bRunCallbacks;

    simWatcher=stm.internal.util.SimulationWatcher(simInput.Model,simInput.HarnessName);
    simWatcher.closeModel=true;

    isIncomplete=false;
    function helperMarkIncomplete(~,~)
        isIncomplete=true;
    end

    isFastRestartFeatureEnabled=false;
    simWatcher.fastRestart=false;
    try
        if(stm.internal.MRT.utility.RunTestConfiguration.checkIfValidSimInput(simInput))
            model=simInput.Model;
            simWatcher.testCaseId=simInput.TestCaseId;
            simWatcher.permutationId=simInput.PermutationId;





            if(simWatcher.revertingFailed)
                runcfg.out.IsIncomplete=true;
                tmpmsg=getString(message('stm:ScriptsView:TestIterationIncompleteDueToEarlierFailures'));
                runcfg.addMessages({tmpmsg},{false});
                return;
            end

            if isempty(model)
                msg=getString(message('stm:general:NoModelSpecified'));
                runcfg.addMessages({msg},{true});
                return;
            end


            if(runcfg.runCallbacks==1)
                me=runcfg.runPreload(simInput);
                if~isempty(me)
                    rethrow(me);
                end
            end


            if(~isa(simWatcher.simModel,'stm.internal.MRT.utility.SimulinkModel'))
                simWatcher.simModel=stm.internal.MRT.utility.SimulinkModel(model,simInput.SubSystem);
                simWatcher.simModel.workerSysPath=workerSysPath;
            end
            runcfg.modelUtil=stm.internal.MRT.utility.SimulinkModel(model,simInput.SubSystem);
            runcfg.modelUtil.workerSysPath=workerSysPath;

            h=addlistener(runcfg.modelUtil,'ModelStopped',@helperMarkIncomplete);
            ocd=onCleanup(@()delete(h));

            if(~simWatcher.modelResolved)
                simWatcher.resolveModelToRun();
            end
            runcfg.modelToRun=simWatcher.modelToRun;


            if(simWatcher.fastRestart==true)
                simMode=simInput.Mode;
                if(isempty(simMode))
                    simMode='Normal';
                end
                if(~isempty(simWatcher.componentUnderTest))

                    simMode=get_param(runcfg.modelToRun,'simulationmode');
                end

                if(~strcmpi(simMode,'Normal')&&~strcmpi(simMode,'Accelerator'))
                    runcfg.addMessages({getString(message('stm:general:FastRestartNotSupported'))},{true});
                    stm.internal.MRT.utility.RunTestConfiguration.deleteModelUtil(runcfg.modelUtil);
                    return;
                end
            end


            try
                if((~isempty(which('bdIsLibrary'))&&bdIsLibrary(runcfg.modelToRun))...
                    ||(~isempty(which('bdIsSubsystem'))&&bdIsSubsystem(runcfg.modelToRun)))
                    libID='Simulink:Engine:NoSimBlockDiagram';
                    libError=getString(message(libID,runcfg.modelToRun,get_param(runcfg.modelToRun,'BlockDiagramType')));
                    throw(MException(libID,libError));
                end
            catch me
                if strcmp(me.identifier,'Simulink:Engine:NoSimBlockDiagram')
                    throw(me);
                end
            end

            currModelStatus=get_param(runcfg.modelToRun,'SimulationStatus');

            isFSOn=false;
            if(isFastRestartFeatureEnabled)
                fRestart=get_param(runcfg.modelToRun,'InitializeInteractiveRuns');
                isFSOn=strcmp(fRestart,'on');
            end


            if(strcmpi(currModelStatus,'stopped')||isFSOn)

                if(~strcmp(runcfg.modelToRun,model))
                    runcfg.modelUtil.HarnessName=runcfg.modelToRun;
                end

                if(runcfg.runCallbacks==1)
                    me=runcfg.runPostload(simInput,simWatcher);
                    if~isempty(me)
                        rethrow(me);
                    end
                end


                simWatcher.originalTopModelDirty=get_param(simInput.Model,'Dirty');


                [simOut,verifyOut,covdata]=runcfg.simulate(simInput,simWatcher,...
                inputDataSetsRunFile,inputSignalGroupRunFile);

                if(simWatcher.revertingFailed)
                    runcfg.addMessages(simWatcher.revertingErrors.messages,simWatcher.revertingErrors.errorOrLog);
                end
                if(isprop(simOut,'sltest_covdata'))
                    simOut=simOut.removeProperty('sltest_covdata');
                end


                runcfg.out.simOut=simOut;

                try
                    if(~isempty(saveRunTo))
                        save(saveRunTo,'simOut','verifyOut');
                    end
                catch
                end

                try
                    if~isempty(covdata)&&~isempty(covSaveTo)
                        cvsave(covSaveTo,covdata);
                    end
                catch
                end
                if(runcfg.runCallbacks==1)
                    simInArrayFeature=slfeature('query','STMSimulationInputArray');
                    useSimInArrayFeature=~isempty(simInArrayFeature)&&simInArrayFeature.State>0;
                    runcfg.runCleanup(simInput,simOut,useSimInArrayFeature);
                end
            else

                msg=getString(message('stm:general:CannotRunModelNotStopped',runcfg.modelToRun));
                runcfg.addMessages({msg},{true});
            end
        else

            runcfg.addMessages({getString(message('stm:general:InvalidSimInputStructure'))},{true});
        end
    catch me
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
        runcfg.addMessages(tempErrors,tempErrorOrLog);
    end
    stm.internal.MRT.utility.RunTestConfiguration.deleteModelUtil(runcfg.modelUtil);


    if(~runcfg.out.IsIncomplete)
        runcfg.out.IsIncomplete=isIncomplete;
    end
end
