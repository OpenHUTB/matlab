function handleDirtyBitChange(this,evt)
    this.Dirty=evt.dirtyFlag;
    this.updateGUITitle();
end
