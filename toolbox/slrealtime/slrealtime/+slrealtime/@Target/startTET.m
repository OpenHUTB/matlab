function startTET(this)














    this.tetStreamingToSDIDueToTETMonitor=false;

    if this.tetStreamingToSDI,return;end

    this.tetStreamingToSDI=true;
    this.tcTETListener.Enabled=true;

    if this.isRunning()&&isempty(this.tetSDISigIds)




        this.addTETToSDI();
    end
end
