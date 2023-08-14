function loadLineProperties(this)





    hPlotter=this.Plotter;
    this.Lines=[hPlotter.Lines,hPlotter.MaxHoldTraceLines,hPlotter.MinHoldTraceLines];
    lineProperties=getPropertyValue(this,'LineProperties');

    if numel(this.Lines)==numel(lineProperties)
        lineProperties=rmfield(lineProperties,'DisplayName');
        for idx=1:numel(this.Lines)
            set(this.Lines(idx),lineProperties(idx));
        end
        storeAllLineProperties(this.Plotter);

        lineVisual_updatePropertyDb(this)
    end
end
