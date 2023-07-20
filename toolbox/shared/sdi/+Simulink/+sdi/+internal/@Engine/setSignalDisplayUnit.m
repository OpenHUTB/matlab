function setSignalDisplayUnit(this,signalID,unit)
    this.sigRepository.setDisplayUnit(signalID,unit);
    Simulink.sdi.WebClient.refreshSignalUnits(signalID);
    notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent(...
    'treeSignalPropertyEvent',signalID,unit,'displayUnits'));
end