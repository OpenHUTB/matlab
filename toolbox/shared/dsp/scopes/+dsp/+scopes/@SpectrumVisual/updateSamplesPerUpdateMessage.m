function updateSamplesPerUpdateMessage(this,visibleFlag)





    hPlotter=this.Plotter;
    if isempty(hPlotter)
        return
    end
    if nargin==1
        visibleFlag=isSourceRunning(this)&&hPlotter.SamplesPerUpdateMsgStatus;
    end
    factor=this.NumSpectralUpdatesPerLine;
    if isSourceRunning(this)
        displaySamplesPerUpdateMsg(hPlotter,visibleFlag,factor);
    elseif~isSourceRunning(this)&&~isempty(this.Plotter.SamplesPerUpdateReadOut)
        displaySamplesPerUpdateMsgOnStop(hPlotter,visibleFlag,factor);
    end
    if hPlotter.SamplesPerUpdateMsgStatus

        if isSpectrogramMode(this)||isCombinedViewMode(this)
            hAxes=this.Axes(1,2);
            map=colormap(ancestor(hAxes,'Figure'));
            bgColor=map(1,:);
            textColor=uiservices.getContrastColor(bgColor);
            set(hPlotter.SamplesPerUpdateReadOut(2),'Color',textColor);
            set(hPlotter.SamplesPerUpdateReadOut(2),'BackgroundColor',bgColor);
        elseif isCombinedViewMode(this)&&~isSpectrogramMode(this)
            hAxes=this.Axes(1,1);
            bgColor=get(hAxes,'Color');
            textColor=uiservices.getContrastColor(bgColor);
            set(hPlotter.SamplesPerUpdateReadOut(1),'Color',textColor);
            set(hPlotter.SamplesPerUpdateReadOut(1),'BackgroundColor',bgColor);
        end


        notify(this,'InvalidateMeasurements');
    end
end
