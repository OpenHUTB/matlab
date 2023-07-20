function parseIMTResultsForSTM(workspaceId,resultID,resultRoot)




    tcrLoc=fullfile(resultRoot,['TestCaseResult_',sprintf('%d',resultID)]);
    testInfoFile=fullfile(tcrLoc,'testInfo.mat');
    testInfo=load(testInfoFile);

    sim1OutputLoc=fullfile(tcrLoc,'PermutationOutput_1');
    sim2OutputLoc=fullfile(tcrLoc,'PermutationOutput_2');
    permLocList={sim1OutputLoc,sim2OutputLoc};




    isMRTEquivTest=length(testInfo.testInfo)>1;
    if isMRTEquivTest
        for idx=1:length(testInfo.testInfo)

            if~isempty(testInfo.testInfo{idx})
                imtResultFile=fullfile(permLocList{idx},'TestResult.mat');
                if(~exist(imtResultFile,'file'))
                    return;
                end
            end
        end
    end

    for permK=1:length(permLocList)
        simOutputLoc=permLocList{permK};
        imtResultFile=fullfile(simOutputLoc,'TestResult.mat');
        if(~exist(imtResultFile,'file'))
            continue;
        end
        imtResult=load(imtResultFile);

        inputSignalGroupRunFile=fullfile(simOutputLoc,'InputSignalGroupRunFile.mat');
        externalInputRunDataSets=fullfile(simOutputLoc,'ExternalInputRunDataSets.mat');

        runFile=fullfile(simOutputLoc,'Run.mat');
        if(~exist(runFile,'file'))
            emptyRun=[];
            save(runFile,'emptyRun');
        end

        try
            out=imtResult.TestResult.simulink_simulate.STM.SimOut;
        catch
            out=struct(...
            'RunID',0,...
            'SimulationFailed',false,...
            'SimulationAsserted',false,...
            'IsIncomplete',false,...
            'SimulationModeUsed','');
            out.messages={};
            out.errorOrLog={};
            out.ExternalInputRunData=repmat(struct('type',[],'runID',[]),1,0);
            out.SigBuilderInfo=struct('SignalSourceComponent','','SignalSourceBlock','');
        end


        isInpRunAvailable=false;

        count=1;
        if(exist(inputSignalGroupRunFile,'file')==2)
            runName=message('stm:objects:ExternalInputSignalGroup').string().char();
            runId=Simulink.sdi.createRun(runName,'file',inputSignalGroupRunFile);
            if~isempty(runId)
                out.ExternalInputRunData(count).type='externalInputSignalGroup';
                Simulink.sdi.internal.moveRunToApp(runId,'stm');
                out.ExternalInputRunData(count).runID=runId;
                count=count+1;
                isInpRunAvailable=true;
            end
        end

        if(exist(externalInputRunDataSets,'file')==2)
            runId=stm.internal.Runs.createInputRunFromMatFile_DataSets(externalInputRunDataSets);
            if~isempty(runId)
                out.ExternalInputRunData(count).type='externalInputDataSets';
                runName=message('stm:objects:ExternalInputDataSets').string().char();
                engine=Simulink.sdi.Instance.engine;
                engine.setRunName(runId,runName);
                out.ExternalInputRunData(count).runID=runId;
                isInpRunAvailable=true;
            end
        end


        if(~isInpRunAvailable)
            out.ExternalInputRunData=[];
        end


        fields={'model_load','model_open','simulink_compile','simulink_simulate'};
        for k=1:length(fields)
            fieldName=fields{k};
            if(isfield(imtResult.TestResult,fieldName))
                if(~imtResult.TestResult.(fieldName).correctness)
                    out.errorOrLog{end+1}=true;
                    out.messages{end+1}=imtResult.TestResult.(fieldName).errormsg;
                    break;
                end
            end
        end

        testInfoFilePath=testInfo.testInfo{permK}.testInfoPath;
        simSettingFile=fullfile(testInfoFilePath,sprintf('simSettings_%d.mat',resultID));
        load(simSettingFile);

        if(permK==1)
            simInData=simSettings.sim1;
        else
            simInData=simSettings.sim2;
        end
        permutationId=simInData.simInput.PermutationId;

        cvtFile=fullfile(simOutputLoc,'CovData.cvt');
        out=processCoverageData(out,simInData.simInput,cvtFile);

        stm.internal.serializePermutationResult(workspaceId,resultID,permutationId,permK,out);
    end
end

function out=processCoverageData(out,simInputs,cvtFile)
    if~exist(cvtFile,'File')
        return;
    end

    [~,cvdata]=cvload(cvtFile);
    assignin('base',stm.internal.Coverage.CovSaveName,cvdata{1});
    out=stm.internal.MRT.utility.getCoverageResults(out,simInputs);
end