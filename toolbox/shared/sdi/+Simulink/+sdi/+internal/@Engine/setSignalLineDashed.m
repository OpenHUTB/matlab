function setSignalLineDashed(this,id,value)
    this.sigRepository.setSignalLineDashed(id,value);
    notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    id,value,'linestyle'));
    value=this.getSignalLine(id);
    this.dirty=true;
    notify(this,'propertyChangeEvent',...
    Simulink.sdi.internal.SDIEvent('propertyChangeEvent',id,...
    Simulink.sdi.internal.StringDict.mgLine,value));
end