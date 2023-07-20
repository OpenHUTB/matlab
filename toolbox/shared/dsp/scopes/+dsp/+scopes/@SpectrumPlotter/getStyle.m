function s=getStyle(this)






    s.FigureColor=get(ancestor(this.Axes(1),'uicontainer'),'BackgroundColor');

    s.AxesColor=get(this.Axes(1),'Color');
    s.AxesTickColor=get(this.Axes(1),'XColor');


    lineNames=get(this.Lines,'DisplayName');
    lineColors=get(this.Lines,'Color');
    lineStyles=get(this.Lines,'LineStyle');
    lineWidths=get(this.Lines,'LineWidth');
    markerStyles=get(this.Lines,'Marker');
    lineVisible=get(this.Lines,'Visible');
    maxHoldLineNames=get(this.MaxHoldTraceLines,'DisplayName');
    maxHoldLineColors=get(this.MaxHoldTraceLines,'Color');
    maxHoldLineStyles=get(this.MaxHoldTraceLines,'LineStyle');
    maxHoldLineWidths=get(this.MaxHoldTraceLines,'LineWidth');
    maxHoldMarkerStyles=get(this.MaxHoldTraceLines,'Marker');
    maxHoldLineVisible=get(this.MaxHoldTraceLines,'Visible');
    minHoldLineNames=get(this.MinHoldTraceLines,'DisplayName');
    minHoldLineColors=get(this.MinHoldTraceLines,'Color');
    minHoldLineStyles=get(this.MinHoldTraceLines,'LineStyle');
    minHoldLineWidths=get(this.MinHoldTraceLines,'LineWidth');
    minHoldMarkerStyles=get(this.MinHoldTraceLines,'Marker');
    minHoldLineVisible=get(this.MinHoldTraceLines,'Visible');
    if~iscell(lineNames)

        lineColors={lineColors};
        lineStyles={lineStyles};
        lineWidths={lineWidths};
        markerStyles={markerStyles};
        lineVisible={lineVisible};
    end
    if~iscell(maxHoldLineNames)
        maxHoldLineNames={maxHoldLineNames};
        maxHoldLineColors={maxHoldLineColors};
        maxHoldLineStyles={maxHoldLineStyles};
        maxHoldLineWidths={maxHoldLineWidths};
        maxHoldMarkerStyles={maxHoldMarkerStyles};
        maxHoldLineVisible={maxHoldLineVisible};
    end
    if~iscell(minHoldLineNames)
        minHoldLineNames={minHoldLineNames};
        minHoldLineColors={minHoldLineColors};
        minHoldLineStyles={minHoldLineStyles};
        minHoldLineWidths={minHoldLineWidths};
        minHoldMarkerStyles={minHoldMarkerStyles};
        minHoldLineVisible={minHoldLineVisible};
    end
    s.LineNames={};
    s.LineColors={};
    s.LineStyles={};
    s.LineWidths={};
    s.MarkerStyles={};
    s.LineVisible={};
    if this.NormalTraceFlag
        for indx=1:numel(this.Lines)
            propVal=get(this.Lines(indx),'DisplayName');
            s.LineNames=[s.LineNames;propVal];
        end
        s.LineColors=[s.LineColors;lineColors];
        s.LineStyles=[s.LineStyles;lineStyles];
        s.LineWidths=[s.LineWidths;lineWidths];
        s.MarkerStyles=[s.MarkerStyles;markerStyles];
        s.LineVisible=[s.LineVisible;lineVisible];
    end
    if this.MaxHoldTraceFlag
        s.LineNames=[s.LineNames;maxHoldLineNames];
        s.LineColors=[s.LineColors;maxHoldLineColors];
        s.LineStyles=[s.LineStyles;maxHoldLineStyles];
        s.LineWidths=[s.LineWidths;maxHoldLineWidths];
        s.MarkerStyles=[s.MarkerStyles;maxHoldMarkerStyles];
        s.LineVisible=[s.LineVisible;maxHoldLineVisible];
    end
    if this.MinHoldTraceFlag
        s.LineNames=[s.LineNames;minHoldLineNames];
        s.LineColors=[s.LineColors;minHoldLineColors];
        s.LineStyles=[s.LineStyles;minHoldLineStyles];
        s.LineWidths=[s.LineWidths;minHoldLineWidths];
        s.MarkerStyles=[s.MarkerStyles;minHoldMarkerStyles];
        s.LineVisible=[s.LineVisible;minHoldLineVisible];
    end
end
