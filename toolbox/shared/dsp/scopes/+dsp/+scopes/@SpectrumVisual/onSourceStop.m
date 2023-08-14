function onSourceStop(this,~,~)






    release(this.SpectrumObject);




    refreshReadouts(this);

    if getPropertyValue(this,'IsCorrectionMode')


        reset(this);
        updateNoDataAvailableMessage(this,true);
        updateSpanReadOut(this,false);
    end
    setPropertyValue(this,'IsCorrectionMode',false);
    updateCorrectionModeMessage(this,false);
    setSpectrumSettingMenus(this,true);


    if~isempty(this.Plotter.SamplesPerUpdateReadOut)
        displaySamplesPerUpdateMsgOnStop(this.Plotter,true);
    end

    if this.SimscapeMode


        this.IsRemoveScreenMsg=~this.InvalidSettingsInSimscapeMode;
    else
        this.IsRemoveScreenMsg=true;
    end
end
