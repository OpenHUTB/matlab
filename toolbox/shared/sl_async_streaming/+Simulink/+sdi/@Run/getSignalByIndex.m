function signal=getSignalByIndex(this,index)




    signalID=this.getSignalIDByIndex(index);
    signal=Simulink.sdi.Signal(this.Repo,signalID);
end
