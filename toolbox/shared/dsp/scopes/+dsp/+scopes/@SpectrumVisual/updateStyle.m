function updateStyle(this,action)





    if this.IsUpdatingStyle


        return;
    end
    this.IsUpdatingStyle=true;
    try

        setPropertyValue(this,'PlotType',this.StyleDialog.PlotType);

        updateStyle@dsp.scopes.LineVisual(this,action);


        refreshStyleDialog(this);
        this.IsUpdatingStyle=false;
    catch
        this.IsUpdatingStyle=false;
    end
end