function startRecording(this)















    if this.Recording
        this.throwError('slrealtime:target:recordingAlreadyStarted',this.TargetSettings.name);
    end



    if this.isConnected&&this.isRunning
        [running,runningAppName]=this.isRunning();
        if running


            hasEnableBlock=false;
            blockToken=strcat(this.appsDirOnTarget,"/",runningAppName,"/misc/enablefilelog.dat");
            if this.isfile(blockToken)
                hasEnableBlock=true;
            end

            if slrealtime.internal.feature('KeepAppDesUIsActiveWhenNotRecording')
                this.Recording=true;

                if this.CreateSDIRunOnStartRecording
                    modelName=this.tc.ModelProperties.Application;
                    targetName=this.TargetSettings.name;



                    this.xcp.stopMeasurement(true);
                    slrealtime.internal.sdi.waitForActiveRunToStop(modelName,targetName);


                    this.xcpStartMeasurement(true);
                    slrealtime.internal.sdi.waitForActiveRunToStart(modelName,targetName);
                end







                for nInst=1:numel(this.RemovedInstruments)
                    this.addInstrument(this.RemovedInstruments(nInst));
                    pause(1);
                end
                this.RemovedInstruments=[];
            else

                this.xcpStartMeasurement(true);
                this.Recording=true;
            end


            if~hasEnableBlock
                this.FileLog.enableLogging;
            end
        end
    end

    this.Recording=true;
    notify(this,'RecordingStarted');
    this.synchAllToolStrips();
end
