function setSignalRelTol(this,id,value)
    this.helperSetTol(id,value,@(id,value)this.sigRepository.setSignalRelTol(id,value),...
    'SDI:sdi:MGAbsTolLbl','rel');
    notify(this,'propertyChangeEvent',...
    Simulink.sdi.internal.SDIEvent('propertyChangeEvent',id,...
    Simulink.sdi.internal.StringDict.mgRelTol,...
    value));
end