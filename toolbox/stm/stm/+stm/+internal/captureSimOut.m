function[out]=captureSimOut(simInput,runID,file,workerId,workerRoot,sheet,range)




    if(nargin<5)
        workerId='';
        workerRoot='';
    end

    saveRunTo='';
    [~,~,ext]=fileparts(file);
    if(~isempty(workerId)&&~isempty(workerRoot))
        saveRunTo=[tempname,'.mat'];
        out=stm.internal.MRT.utility.runTestConfiguration(workerId,workerRoot,...
        simInput,0,saveRunTo,'','');
        c=onCleanup(@()helperDeleteRunFile(saveRunTo));

        stm.internal.util.createRunFromMatFile(saveRunTo,runID);
        out.RunID=runID;
    else
        simWatcher=stm.internal.util.SimulationWatcher(simInput.Model,simInput.HarnessName);

        moveRun=~strcmpi(ext,'.mldatx');
        out=stm.internal.runTestConfiguration(simInput,runID,simWatcher,[],[],[],moveRun);
        simWatcher.delete();
    end


    engine=Simulink.sdi.Instance.engine;
    if(engine.isValidRunID(out.RunID))
        sigCount=length(engine.getAllSignalIDs(out.RunID));

        if sigCount>0




            if(out.RunID~=runID||simInput.RunOnTarget)
                runID=out.RunID;
                engine=Simulink.sdi.Instance.engine;



                hasVerify=stm.internal.hasVerifySignal(runID);


                if(hasVerify)
                    engine.safeTransaction(@helperDeleteSignals,engine,runID);
                end
            end


            sigSet=stm.internal.MRT.utility.getLoggedSignalSet(simInput);
            hasFilteredSigs=false;
            if(sigSet~=0)
                hasFilteredSigs=stm.internal.applyLoggedSignalSetProperties(sigSet,runID);
            end

            if(slfeature('STMOutputTriggering')>0)
                stm.internal.trigger.filterSignalLoggingOnTriggers(runID,simInput,out.simOut);


                simInOTIStruct=simInput.OutputTriggering;
                hasFilteredSigs=simInOTIStruct.StartTriggerMode>0||simInOTIStruct.StopTriggerMode>0;
            end

            if strcmpi(ext,'.mat')
                if~isempty(saveRunTo)&&~hasFilteredSigs
                    movefile(saveRunTo,file,'f');
                else
                    runObj=Simulink.sdi.getRun(runID);
                    runObj.export('to','file','fileName',file);
                end
            elseif strcmpi(ext,'.mldatx')
                stm.internal.saveRunToMLDATX(file,runID);
                Simulink.sdi.internal.moveRunToApp(runID,'stm');
            else
                run=Simulink.sdi.getRun(runID);
                baseDS=run.export();


                xls.internal.util.writeDatasetToSheet(baseDS,file,sheet,range,xls.internal.SourceTypes.Output);
            end
        end
    end
end

function helperDeleteRunFile(runfile)
    if(exist(runfile,'file'))
        delete(runfile);
    end
end

function helperDeleteSignals(engine,runID)
    verifySignalIDs=Simulink.sdi.DatasetRef(runID,'slt_verify').getSortedSignalIDs();
    if~isempty(verifySignalIDs)
        engine.deleteSignal(verifySignalIDs);
    end
end

