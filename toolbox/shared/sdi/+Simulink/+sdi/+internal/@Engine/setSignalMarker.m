function setSignalMarker(this,id,value)
    this.sigRepository.setSignalMarker(id,value);
    value=this.getSignalLine(id);
    this.dirty=true;
    notify(this,'propertyChangeEvent',...
    Simulink.sdi.internal.SDIEvent('propertyChangeEvent',id,...
    Simulink.sdi.internal.StringDict.mgLine,value));
end