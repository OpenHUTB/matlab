function setSignalUnit(this,signalID,unit)
    this.sigRepository.setUnit(signalID,unit);
    Simulink.sdi.WebClient.refreshSignalUnits(signalID);
    notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent(...
    'treeSignalPropertyEvent',signalID,unit,'units'));
end