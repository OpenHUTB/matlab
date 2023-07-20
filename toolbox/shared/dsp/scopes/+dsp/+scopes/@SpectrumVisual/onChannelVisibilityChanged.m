function onChannelVisibilityChanged(this)





    storeAllLineProperties(this.Plotter);
    lineVisual_updatePropertyDb(this);



    if~isempty(this.StyleDialog)&&this.StyleDialog.Visible
        refreshStyleDialog(this);
    end