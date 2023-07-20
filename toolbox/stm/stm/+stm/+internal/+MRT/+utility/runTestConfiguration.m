function out=runTestConfiguration(workerName,workerRoot,...
    simInput,runId,saveRunTo,...
    inputDataSetsRunFile,inputSignalGroupRunFile)








    out=[];
    if(isempty(workerName)&&isempty(workerRoot))
        return;
    end

    testCaseId=simInput.TestCaseId;
    iterationId=simInput.IterationId;
    permIds=stm.internal.getPermutations(testCaseId);
    if(isempty(permIds))
        return;
    end
    if(simInput.PermutationId==permIds(1))
        simIndex=1;
    elseif(length(permIds)==2&&simInput.PermutationId==permIds(2))
        simIndex=2;
    else
        return;
    end
    workspaceRoot=stm.internal.MRT.utility.createWorkspace(0,1,false);
    workerSysPath=fullfile(workspaceRoot,'Workers');
    if(~exist(workerSysPath,'dir'))
        return;
    end

    tmpSaveRunTo=saveRunTo;
    if(isempty(tmpSaveRunTo))
        tmpSaveRunTo=[tempname(workspaceRoot),'.mat'];
        c=onCleanup(@()deleteFile(tmpSaveRunTo));
    end

    [runcfg,simInput]=stm.internal.MRT.utility.getSimulationSettings(testCaseId,iterationId,simIndex-1);
    if(simIndex==1)
        simSettings.sim1.runcfg=runcfg;
        simSettings.sim1.simInput=simInput;
        simSettings.sim2=[];
    else
        simSettings.sim1=[];
        simSettings.sim2.runcfg=runcfg;
        simSettings.sim2.simInput=simInput;
    end

    infoFilePath=fullfile(workspaceRoot,'TestInfo',workerName);
    if(~exist(infoFilePath,'dir'))
        mkdir(infoFilePath);
    end
    simSettingFile=[tempname(infoFilePath),'.mat'];
    save(simSettingFile,'simSettings');
    c2=onCleanup(@()deleteFile(simSettingFile));

    params={simSettingFile,sprintf('%d',simIndex),'1',...
    workerSysPath,tmpSaveRunTo,'',...
    inputDataSetsRunFile,inputSignalGroupRunFile};
    paramStr=join(params,''',''');
    cmdStr=['out = stm.internal.MRT.utility.runTestConfigurationMRT(''',paramStr{1},''');'];

    pool=stm.internal.MRT.mrtpool.getInstance;
    pool.addWorker(workerName,workerRoot,'');

    workerId=pool.findWorkerByPath(workerRoot);
    out=pool.run(workerId,cmdStr,{'out'},true,{});
    if(runId>0)
        stm.internal.util.createRunFromMatFile(tmpSaveRunTo,runId);
        out.RunID=runId;
    end
end

function deleteFile(fileName)
    warnstat=warning('query','all');
    warning('off','MATLAB:DELETE:FileNotFound');
    warning('off','MATLAB:DELETE:Permission');
    wCleanup=onCleanup(@()warning(warnstat));

    if(exist(fileName,'file'))
        try
            delete(fileName);
        catch
        end
    end
end
