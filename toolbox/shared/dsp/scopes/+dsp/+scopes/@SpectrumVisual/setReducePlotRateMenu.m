function setReducePlotRateMenu(this,eventData)



    this.ReduceUpdates=getPropertyValue(this,eventData);
    if this.ReduceUpdates
        val='on';
        this.SpectrumObject.ReduceUpdates=true;
        this.DataBuffer.setReduceUpdates(true);
    else
        val='off';
        this.SpectrumObject.ReduceUpdates=false;
        this.DataBuffer.setReduceUpdates(false);
    end
    if isfield(this.Handles,'ReduceUpdatesMenu')
        set(this.Handles.ReduceUpdatesMenu,'Checked',val);
    end
