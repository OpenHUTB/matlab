function stopRecording(this)














    stopProps=this.get('StopProperties');

    if~this.Recording
        this.throwError('slrealtime:target:recordingAlreadyStopped',this.TargetSettings.name);
    end


    this.StopRecordingBusy=true;


    cleanupStopRecording=onCleanup(@()this.cleanupAsyncFlags());



    if this.isConnected&&this.isRunning
        [running,runningAppName]=this.isRunning();
        if running

            hasEnableBlock=false;
            blockToken=strcat(this.appsDirOnTarget,"/",runningAppName,"/misc/enablefilelog.dat");
            if this.isfile(blockToken)
                hasEnableBlock=true;
            end


            if~hasEnableBlock
                this.FileLog.disableLogging;
            end


            try



                hasFileLogRun=false;
                if this.StopProperties.AutoImportFileLog&&~hasEnableBlock
                    appName=string(this.tc.ModelProperties.Application);
                    try

                        runs=slrealtime.internal.logging.legitimizeRequest(appName,'Target',this);
                    catch

                        runs=[];
                    end
                    if~isempty(runs)

                        this.FileLog.BufferedLogger.fetch(runs(height(runs),:));
                        this.FileLog.BufferedLogger.import();
                        hasFileLogRun=true;
                    end
                end



                if this.StopProperties.ExportToBaseWorkspace
                    slrealtime.internal.exportSignals(this,hasFileLogRun);
                end
            catch ME
                this.throwError('slrealtime:target:stopRecordingError',this.TargetSettings.name,ME.message);
            end

            if slrealtime.internal.feature('KeepAppDesUIsActiveWhenNotRecording')




                this.CreateSDIRunOnStartRecording=true;
                this.RemovedInstruments=this.instrumentList(arrayfun(@(x)x.StreamingOnly&&~isempty(x.signals),this.instrumentList));
                for nInst=1:numel(this.RemovedInstruments)
                    this.removeInstrument(this.RemovedInstruments(nInst));
                end
            else

                this.xcp.stopMeasurement(true);
            end




            this.FileLog.BufferedLogger.close();
        end
    end

    this.Recording=false;
    this.StopRecordingBusy=false;
    notify(this,'RecordingStopped');
    this.synchAllToolStrips();

    if this.XCPDisconnectInterrupted
        this.xcpDisconnect();


        this.cleanupRecording();




        if(stopProps.ReloadOnStop)
            tc=this.get('tc');
            this.load(tc.ModelProperties.Application,'AsynchronousLoad',true,'SkipInstall',true);
        end
    end
end
