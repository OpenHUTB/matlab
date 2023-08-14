function setSignalLineColor(this,id,value)
    this.sigRepository.setSignalLineColor(id,value);
    notify(this,'treeSignalPropertyEvent',Simulink.sdi.internal.SDIEvent('treeSignalPropertyEvent',...
    id,value,'color'));
    value=this.getSignalLine(id);
    this.dirty=true;
    notify(this,'propertyChangeEvent',...
    Simulink.sdi.internal.SDIEvent('propertyChangeEvent',id,...
    Simulink.sdi.internal.StringDict.mgLine,value));
end