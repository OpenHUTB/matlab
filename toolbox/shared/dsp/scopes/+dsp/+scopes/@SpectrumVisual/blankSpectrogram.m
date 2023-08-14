function blankSpectrogram(this,removeTicksFlag)






    if~(isSpectrogramMode(this)||isCombinedViewMode(this))
        return
    end
    if nargin==1
        removeTicksFlag=true;
    end
    hPlotter=this.Plotter;
    if~isempty(hPlotter)
        cdata=get(hPlotter.hImage,'Cdata');
        if isempty(cdata)
            hPlotter.TimeVector=[-1,0];
            hPlotter.TimeSpan=1;
            set(this.Axes(1,2),'XLim',[0,1]);
            set(this.Axes(1,2),'YLim',[-1,0]);
            set(hPlotter.hImage,'XData',[0,1]);
            set(hPlotter.hImage,'YData',[-1,0]);
            set(hPlotter.hImage,'Cdata',-inf(2,2));
        else
            set(hPlotter.hImage,'Cdata',-inf(size(cdata)));
        end
        if removeTicksFlag
            updateXAxisLabels(hPlotter,false);
            updateYAxisLabels(hPlotter,false);
            hXlabel=get(this.Axes(1,2),'XLabel');
            set(hXlabel,'String',uiscopes.message('FrequencyXLabel'));
            set(hXlabel,'Visible','on');
        end
    end
end
