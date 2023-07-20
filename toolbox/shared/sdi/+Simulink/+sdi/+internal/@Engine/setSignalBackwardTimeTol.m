function setSignalBackwardTimeTol(this,id,value)
    this.helperSetTol(id,value,@(id,value)this.sigRepository.setSignalBackwardTimeTol(id,value),...
    'SDI:sdi:LaggingTol','laggingTol');
    notify(this,'propertyChangeEvent',...
    Simulink.sdi.internal.SDIEvent('propertyChangeEvent',id,...
    Simulink.sdi.internal.StringDict.mgLaggingTol,...
    value));
end
