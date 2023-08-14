function disconnectTarget(this)





    if~isempty(this.tc)
        this.tc.closeChannel;

        delete(this.tcLoadedListener);
        this.tcLoadedListener=[];
        this.tcLoadFailedListener=[];
        delete(this.tcStartedListener);
        this.tcStartedListener=[];
        delete(this.tcStoppedListener);
        this.tcStoppedListener=[];
        delete(this.tcTargetConnListener);
        this.tcTargetConnListener=[];
        delete(this.tcTETListener);
        this.tcTETListener=[];

    end

    if~isempty(this.ptpd)
        delete(this.ptpd);
        this.ptpd=[];
    end

    if~isempty(this.TargetSettings)
        slrealtime.TETMonitor.remove(this.TargetSettings.name);
    end

    if~isempty(this.FileLog)


        this.FileLog.BufferedLogger.close()
    end
end
