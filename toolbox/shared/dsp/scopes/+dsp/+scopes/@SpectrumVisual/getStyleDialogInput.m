function ip=getStyleDialogInput(this)





    ip=this.Plotter.getStyle;
    ip.SelectedDisplay=1;
    ip.DisplayNames={'1'};
    ip.DialogName=this.Application.getDialogTitle(false,'style');
    ip.PlotType=getPropertyValue(this,'PlotType');
    ip.PlotTypeEnums={'Line';'Stem'};

    ip.ViewType=getPropertyValue(this,'ViewType');
    ip.NormalTraceFlag=getPropertyValue(this,'NormalTrace');
end
