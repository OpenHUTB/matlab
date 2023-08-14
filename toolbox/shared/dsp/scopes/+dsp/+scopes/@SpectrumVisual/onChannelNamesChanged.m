function onChannelNamesChanged(this)






    updatePropertySet(this);

    if~isempty(this.StyleDialog)
        if this.StyleDialog.Visible
            ln=get(this.Lines,'DisplayName');
            if~iscell(ln)
                ln={ln};
            end
            this.StyleDialog.LineNames=ln;
        end
    end
    storeAllLineProperties(this.Plotter);

    updateSpanReadOut(this)
    if this.IsSystemObjectSource&&this.ReduceUpdates
        this.DataBuffer.restartTimer();
    end

    dlgObject=getSpectrumSettingsDialog(this);
    if~isempty(dlgObject)
        refreshDlgProp(dlgObject,'ChannelNumber');
    end
    notify(this,'DisplayUpdated');
end
