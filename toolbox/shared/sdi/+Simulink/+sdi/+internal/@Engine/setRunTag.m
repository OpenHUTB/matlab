function setRunTag(this,runID,tag)
    this.sigRepository.setRunTag(runID,tag);
    this.dirty=true;
    notify(this,'propertyChangeEvent',...
    Simulink.sdi.internal.SDIEvent('propertyChangeEvent',runID,...
    Simulink.sdi.internal.StringDict.mgRunName,...
    tag));
    notify(this,'treeRunPropertyEvent',...
    Simulink.sdi.internal.SDIEvent('treeRunPropertyEvent',...
    runID,tag,'runTag'));
end