function setSignalDataType(this,id,value)
    this.sigRepository.changeSignalDataType(id,value);
    Simulink.sdi.WebClient.refreshDataType(id);
    notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    id,value,'dataType'));
    this.dirty=true;
end