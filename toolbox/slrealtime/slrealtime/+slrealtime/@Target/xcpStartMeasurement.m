function xcpStartMeasurement(this,varargin)







    if nargin>1
        startRecording=varargin{1};
    else
        startRecording=false;
    end


    if~this.Recording&&~startRecording
        this.FileLog.disableLogging;
        return;
    end

    appName=this.tc.ModelProperties.Application;
    ModelName=this.tc.ModelProperties.ModelName;

    if isempty(this.xcp)



        slrealtime.internal.throw.Warning('slrealtime:target:applicationConnectionFailed',...
        appName,this.TargetSettings.name,message('slrealtime:target:noXCPConnection').string);
        return;
    end



    clients=Simulink.HMI.StreamingClients(ModelName);






    if isempty(this.streamingAcquireList)&&isempty(this.instrumentList)
        hInst=slrealtime.Instrument(this.getAppFile(appName));
        hInst.RemoveOnStop=true;
        hInst.StreamingOnly=true;
        hInst.addInstrumentedSignals();
        this.addInstrument(hInst,false);
    end




    ALM=this.streamingAcquireList.AcquireListModel;
    ALM.targetName=this.TargetSettings.name;
    ALM.buildDirectory=this.mldatxCodeDescFolder;
    try
        assert(~isempty(this.xcp),'No XCP Connection');

        numTasks=getNumTasks(this.mldatxMiscFolder);


        if startRecording
            sdiRunCreated=this.xcp.startMeasurement(clients,ALM,true,this.ModelStatus.ExecTime,numTasks);
        else
            sdiRunCreated=this.xcp.startMeasurement(clients,ALM,false,this.ModelStatus.ExecTime,numTasks);
        end
    catch ME
        this.throwError('slrealtime:target:streamingToSDINotAvailable',...
        appName,this.TargetSettings.name,ME.message);
    end




    this.SDIRunId=[];
    if sdiRunCreated

        if~isdeployed
            this.SDIRunId=slrealtime.internal.sdi.getActiveRunId(ModelName,this.TargetSettings.name);
        end
        if isempty(this.SDIRunId)

        else
            try
                slrealtime.internal.sdi.setRunMetaData(this.SDIRunId,...
                ModelName,this.TargetSettings.name,this.slrtApp);
            catch e
                if strcmp(e.identifier,'slrealtime:application:packageNotFound')



                    xcpExtractFromApp(this,appName);
                    slrealtime.internal.sdi.setRunMetaData(this.SDIRunId,...
                    ModelName,this.TargetSettings.name,this.slrtApp);
                else
                    rethrow(e);
                end
            end

            slrealtime.internal.sdi.start(this.SDIRunId,...
            ModelName,this.TargetSettings.name,[]);
        end
    end






    if this.tetStreamingToSDI&&isempty(this.tetSDISigIds)
        this.addTETToSDI();
    end

    currentDir=pwd;
    try
        cd(this.mldatxMiscFolder);






        if isdeployed
            taskInfoFile='slrealtime_task_info.m';
            fileText=regexp(fileread(taskInfoFile),newline,'split');
            eval(strjoin(fileText(2:end-2),newline));

            taskInfos=taskInfo;
            numTasks=numtask;
        else

            [taskInfos,numTasks,~]=eval('slrealtime_task_info');
        end
    catch e
        cd(currentDir);
        rethrow(e);
    end
    cd(currentDir);
    for nTask=1:numTasks
        tetInfo(nTask)=struct(...
        'name',taskInfos(nTask).taskName,...
        'sampleTimeStr',num2str(taskInfos(nTask).samplePeriod));%#ok
    end
    slrealtime.TETMonitor.activate(...
    this.TargetSettings.name,ModelName,tetInfo);


    notify(this,'RecordingStarted');
    this.synchAllToolStrips();
end

function numTasks=getNumTasks(mldatxMiscFolder)
    currentDir=pwd;
    try
        cd(mldatxMiscFolder);
        if isdeployed
            taskInfoFile='slrealtime_task_info.m';
            fileText=regexp(fileread(taskInfoFile),newline,'split');
            eval(strjoin(fileText(2:end-2),newline));
            numTasks=numtask;
        else
            [~,numTasks,~]=slrealtime_task_info;
        end
    catch e
        cd(currentDir);
        rethrow(e);
    end
    cd(currentDir);
end
