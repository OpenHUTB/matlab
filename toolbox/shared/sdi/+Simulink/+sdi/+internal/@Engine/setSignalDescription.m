function setSignalDescription(this,id,value)
    this.sigRepository.setSignalDescription(id,value);
    notify(this,...
    'treeSignalPropertyEvent',...
    Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    id,...
    value,...
    'Description'));
end