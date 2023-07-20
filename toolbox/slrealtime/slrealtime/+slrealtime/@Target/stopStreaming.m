function stopStreaming(this)













    if~this.isConnected()
        this.connect;
    end

    try
        this.removeInstrument(this.BindModeInstrument);
    catch
    end

    this.BindModeDataMap=[];
    this.BindModeInstrument=[];
    this.BindModeModelName=[];

    this.synchAllToolStrips();
end
