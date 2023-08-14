










function runCfgOut=constructRunCfgOut(runCfg,simInStruct,simWatcher,cacheSimOut,simOut)
    try
        [~,~,isModeAppliedOnCUT,simModeForCUT]=...
        runCfg.getSimMode(simInStruct,simWatcher);

        if(cacheSimOut)
            runCfg.out.simOut=simOut;
        end


        warnings=simOut.SimulationMetadata.ExecutionInfo.WarningDiagnostics;

        for i=1:numel(warnings)
            if~(strcmp(warnings(i).Diagnostic.identifier,'Simulink:Logging:TopMdlOverrideUpdated'))
                runCfg.out.messages{end+1}=stm.internal.util.getDiagnosticMessage(warnings(i).Diagnostic);
                runCfg.out.errorOrLog{end+1}=false;
            end
        end


        if runCfg.runUsingSimIn

            runCfg.out.overridesilpilmode=simInStruct.OverrideSILPILMode;
        else

            runCfg.out.overridesilpilmode=false;
        end


        runCfg.out.OutputTriggerInfo=simInStruct.OutputTriggering;

        if(slfeature('STMOutputTriggering')==0)
            runCfg.out.OutputTriggerInfo.TimeDiff=0;
        end

        runCfg.out.modelChecksum=[];
        mdata=[];

        if~isempty(simOut)
            mdata=simOut.getSimulationMetadata();
        end

        runCfg.out=stm.internal.util.getSimulationMetadata(runCfg.out,mdata,runCfg.modelToRun,runCfg.modelToRun);
        if strcmpi(mdata.ExecutionInfo.StopEvent,'StopCommand')

            runCfg.out.IsIncomplete=true;
        end

        if(isfield(runCfg.out,'simMode'))

            if(isModeAppliedOnCUT&&~isempty(simModeForCUT))
                runCfg.out.SimulationModeUsed=simModeForCUT;
            else
                runCfg.out.SimulationModeUsed=runCfg.out.simMode;
            end
        end

        if(~isempty(simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic))
            me=simOut.SimulationMetadata.ExecutionInfo.ErrorDiagnostic.Diagnostic;



            if strcmp(me.identifier,'Simulink:Commands:SimInputPrePostFcnError')
                actualCause=me.cause;
                if isa(me,'MSLException')
                    actualCause{1}.throw;
                else
                    actualCause{1}.reportAsError;
                end
            end


            runCfg.out.SimulationFailed=true;
            if strcmp(me.identifier,'Simulink:tools:rapidAccelAssertion')||...
                strcmp(me.identifier,'Simulink:blocks:AssertionAssert')
                runCfg.out.SimulationAsserted=true;
            end
            throwWithSimDiagnostic(me);
        end

        if(~runCfg.out.SimulationFailed)
            runCfg.out=stm.internal.Coverage.getCoverageResults(runCfg.out,simWatcher,simInStruct,simOut);
        end


        runCfg.out.OutputSignalSetUsed=stm.internal.MRT.utility.getLoggedSignalSet(simInStruct);

        runCfgOut=runCfg.out;
    catch me
        stm.internal.SimulationInput.addExceptionMessages(runCfg,me);

        if(runCfg.out.SimulationAsserted)
            runCfg.out=stm.internal.Coverage.getCoverageResults(runCfg.out,simWatcher,simInStruct);
        end
        runCfgOut=runCfg.out;
    end
end

function throwWithSimDiagnostic(simException)
    errID='stm:general:ErrorCallingSim';
    if(isa(simException,'MSLException'))
        diag=MSLException(message(errID,simException.identifier));
        diag=diag.addCause(simException);
        diag.throw;
    else
        diag=MSLDiagnostic(message(errID,simException.identifier));
        diag=diag.addCause(simException);
        diag.reportAsError;
    end
end
