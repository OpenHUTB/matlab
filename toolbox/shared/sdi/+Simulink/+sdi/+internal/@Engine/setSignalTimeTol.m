function setSignalTimeTol(this,id,value)
    this.helperSetTol(id,value,@(id,value)this.sigRepository.setSignalTimeTol(id,value),...
    'SDI:sdi:TimeTol','timeTol');
    notify(this,'propertyChangeEvent',...
    Simulink.sdi.internal.SDIEvent('propertyChangeEvent',id,...
    Simulink.sdi.internal.StringDict.mgTimeTol,...
    value));
end
