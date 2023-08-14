function xcpDisconnect(this)







    if this.StopRecordingBusy
        this.XCPDisconnectInterrupted=true;
        return;
    end



    if~isempty(this.xcp)
        try


            hasFileLogRun=false;
            if(this.StopProperties.AutoImportFileLog)
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
            slrealtime.internal.throw.Warning('slrealtime:target:postStopError',this.TargetSettings.name,ME.message);
        end


        this.xcp.stopMeasurement(false);


        this.FileLog.BufferedLogger.close();



        pause(1);

        delete(this.xcp);
        this.xcp=[];

        OnStartFlag=false;
        this.refreshInstrumentList(OnStartFlag);

        this.slrtApp=[];
        this.mldatxCodeDescFolder=[];
        this.mldatxMiscFolder=[];
        this.tetSDISigIds=[];







    end

    this.cleanupCANBusLogging();

    slrealtime.TETMonitor.deactivate(this.TargetSettings.name);

end
