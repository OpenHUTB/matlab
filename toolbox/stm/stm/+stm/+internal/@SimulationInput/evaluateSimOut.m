












function evaluateSimOut(simOut,useParallel,simInStruct,simWatcher,runCfg,resultSetId)

    clearVarsCleanup=onCleanup(@()clearLoadedVars(simWatcher));
    runId=simInStruct.RunID;
    permutationId=simInStruct.PermutationId;
    iterationId=simInStruct.IterationId;
    testCaseId=simInStruct.TestCaseId;
    cacheSimOut=simInStruct.CacheSimOut;

    try






        if~bdIsLoaded(runCfg.modelToRun)
            if~isempty(simWatcher.harnessName)
                stm.internal.util.deactivateAndloadHarness(simWatcher.ownerName,simWatcher.harnessName,simInStruct.Model);
            else
                load_system(runCfg.modelToRun);
            end
        end

        streamedRunId=0;

        engine=Simulink.sdi.Instance.engine;

        preSimRunID=0;
        if(isprop(simOut,'preSimRunID'))
            preSimRunID=simOut.preSimRunID;
            simOut=simOut.removeProperty('preSimRunID');
        end

        postSimRunID=0;
        if(isprop(simOut,'postSimRunID'))
            postSimRunID=simOut.postSimRunID;
            simOut=simOut.removeProperty('postSimRunID');
        end

        if(useParallel&&isprop(simOut,'ExternalInputRunDataworkerRun'))
            workerRun=simOut.ExternalInputRunDataworkerRun;
            simOut=simOut.removeProperty('ExternalInputRunDataworkerRun');
            localRun=getLocalRun(workerRun);
            streamedRunId1=localRun.id;
            stm.internal.RunTestConfiguration.moveRunToApp(streamedRunId1);
            runCfg.out.ExternalInputRunData.runID=streamedRunId1;
        end

        if(~isequal(preSimRunID,postSimRunID)||isprop(simOut,'workerRun'))






            if(useParallel&&isprop(simOut,'workerRun'))
                workerRun=simOut.workerRun;
                simOut=simOut.removeProperty('workerRun');
                localRun=getLocalRun(workerRun);
                streamedRunId=localRun.id;
            else
                streamedRunId=postSimRunID;
            end
        end

        if isequal(streamedRunId,0)
            streamedRunId=runId;
        else
            if(slfeature('STMOutputTriggering')>0)
                simInStruct=stm.internal.trigger.filterSignalLoggingOnTriggers(streamedRunId,simInStruct,simOut);
            end
            stm.internal.RunTestConfiguration.moveRunToApp(streamedRunId);
        end

        metadata=[];

        if~isempty(simOut)
            metadata=simOut.getSimulationMetadata();
        end

        ws=warning('off','SDI:sdi:notValidBaseWorkspaceVar');
        cleanupWarning=onCleanup(@()warning(ws));

        if(engine.getSignalCount(streamedRunId)==0)
            noLoggedDataMsg=getString(message('stm:general:NoLoggedSignals',runCfg.modelToRun));
            runCfg.addMessages({noLoggedDataMsg},{false});
        end


        if~isempty(metadata)
            for warnDiagnostic=metadata.ExecutionInfo.WarningDiagnostics.'
                diag=warnDiagnostic.Diagnostic;
                idx={diag.identifier}=="Simulink:Engine:NonTunableVarChangedInFastRestart";
                runCfg.addMessages({diag(idx).message},repmat({true},[1,nnz(idx)]));
            end
        end

        cleanupStruct=simWatcher.cleanupTestCase;
        mdl=simWatcher.modelToRun;

        if~simWatcher.fastRestart
            if isfield(cleanupStruct,'removeConfigSet')||isfield(cleanupStruct,'removeConfigSet1')
                if isfield(cleanupStruct,'currConfigSet')
                    preserveDirty=Simulink.PreserveDirtyFlag(get_param(simWatcher.modelToRun,'Handle'),'blockDiagram');
                    setActiveConfigSet(mdl,cleanupStruct.currConfigSet.Name);
                    delete(preserveDirty);
                    cleanupStruct.currConfigSet=[];
                end



                if isfield(cleanupStruct,'removeConfigSet')
                    detachConfigSet(mdl,cleanupStruct.removeConfigSet);
                    cleanupStruct.removeConfigSet=[];
                end
                if isfield(cleanupStruct,'removeConfigSet1')
                    preserveDirty=Simulink.PreserveDirtyFlag(get_param(simWatcher.modelToRun,'Handle'),'blockDiagram');
                    detachConfigSet(mdl,cleanupStruct.removeConfigSet1);
                    delete(preserveDirty);
                    cleanupStruct.removeConfigSet1=[];
                end
                if isfield(cleanupStruct,'Dirty')
                    set_param(mdl,'Dirty',cleanupStruct.Dirty);
                    cleanupStruct.Dirty=[];
                end
            else
                if isfield(cleanupStruct,'currConfigSet')
                    setActiveConfigSet(simWatcher.modelToRun,cleanupStruct.currConfigSet.Name);
                    cleanupStruct.currConfigSet=[];
                end
            end
        end






        if useParallel
            if isprop(simOut,'mlFigures')&&~isempty(simOut.mlFigures)
                getArrayFromByteStream(simOut.mlFigures);
                simOut=simOut.removeProperty('mlFigures');
            end
            if isprop(simOut,'cleanupCBMLFigures')&&~isempty(simOut.cleanupCBMLFigures)
                getArrayFromByteStream(simOut.cleanupCBMLFigures);
                simOut=simOut.removeProperty('cleanupCBMLFigures');
            end
        end

        runCfg.out.RunID=streamedRunId;
        if isprop(simOut,'cleanupCBException')&&~isempty(simOut.cleanupCBException)
            stm.internal.SimulationInput.addExceptionMessages(runCfg,simOut.cleanupCBException);
            simOut=simOut.removeProperty('cleanupCBException');
        end

        runCfgOut=stm.internal.SimulationInput.constructRunCfgOut(runCfg,simInStruct,simWatcher,cacheSimOut,simOut);

        stm.internal.SimulationInput.cleanupSignalBuilder(simWatcher);

        if slfeature('STMTestSequenceScenario')
            stm.internal.SimulationInput.cleanupTestSequenceScenario(simWatcher);
        end

    catch me
        stm.internal.SimulationInput.addExceptionMessages(runCfg,me);
        runCfgOut=runCfg.out;
    end


    stm.internal.processSimOutResults(runCfgOut,permutationId,iterationId,testCaseId,useParallel,resultSetId,simInStruct.RunID);
end

function clearLoadedVars(simWatcher)
    if isfield(simWatcher.cleanupIteration,'VarsLoaded')&&...
        ~isempty(simWatcher.cleanupIteration.VarsLoaded)
        evalin('base',['clear ',char(join(simWatcher.cleanupIteration.VarsLoaded))]);
    end
end
