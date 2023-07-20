function exportStreaming(this)













    if~this.isConnected()
        this.connect;
    end

    [file,path]=uiputfile('*.mat',message('slrealtime:target:exportInstrumentTitle').getString());
    if file==0

        return
    end

    try

        this.removeInstrument(this.BindModeInstrument);
        this.BindModeInstrument.validate([]);
    catch
    end

    c=onCleanup(@()this.addInstrument(this.BindModeInstrument));

    BindModeDataMap=this.BindModeDataMap;
    pInst=this.BindModeInstrument;
    BindModeModelName=this.BindModeModelName;
    save(fullfile(path,file),'BindModeDataMap','pInst','BindModeModelName');
end

