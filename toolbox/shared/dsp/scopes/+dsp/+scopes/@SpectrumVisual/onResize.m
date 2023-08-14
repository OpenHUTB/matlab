function onResize(this)




    updateInset(this);
    updateSpanReadOut(this);
    if~this.IsSystemObjectSource
        updateSamplesPerUpdateMessage(this,true);
    else
        updateSamplesPerUpdateMessage(this);
    end
    updateNoDataAvailableMessage(this);
    updateCorrectionModeMessage(this);
    updateColorBar(this);

    hAxes=this.Axes;
    pos=get(hAxes,'Position');
    pos=cell2mat(pos);
    if any(isnan(pos))
        set(hAxes,'OuterPosition',[0,0,1,1])
    end
end
