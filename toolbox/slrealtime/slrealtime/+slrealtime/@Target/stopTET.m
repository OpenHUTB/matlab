function stopTET(this)













    this.tetStreamingToSDIDueToTETMonitor=false;

    if~this.tetStreamingToSDI,return;end

    wasStreaming=...
    this.isRunning()&&...
    ~isempty(this.tetSDISigIds)&&...
    this.tetStreamingToSDI;

    this.tetStreamingToSDI=false;



    if~isempty(this.tcTETListener)
        this.tcTETListener.Enabled=false;
    end

    if wasStreaming



        repository=sdi.Repository(true);
        time=this.tc.ModelExecProperties.ExecTime;
        for i=1:length(this.tetSDISigIds)
            repository.addSignalTimePoint(this.tetSDISigIds(i),time,nan);
        end
    end
end
