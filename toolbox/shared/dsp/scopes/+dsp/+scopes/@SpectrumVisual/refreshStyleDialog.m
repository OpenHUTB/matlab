function refreshStyleDialog(this)





    hPlotter=this.Plotter;
    if isempty(hPlotter)
        return
    end

    if~isempty(this.StyleDialog)&&this.StyleDialog.Visible
        ip=getStyleDialogInput(this);
        if~isempty(ip)
            initialize(this.StyleDialog,ip);
        end
    end
end
