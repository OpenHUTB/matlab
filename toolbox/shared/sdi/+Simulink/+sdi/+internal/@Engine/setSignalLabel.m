function setSignalLabel(this,id,value)

    this.sigRepository.setSignalLabel(id,value);
    notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    id,value,'signalLabel'));
    Simulink.sdi.SignalClient.publishSignalLabels(id);
    this.dirty=true;
end