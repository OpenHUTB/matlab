function updateInset(this)




    if this.IsVisualStartingUp
        return
    end
    insetFactor=1;
    titleFactor=0;
    if isSpectrogramMode(this)

        title=getPropertyValue(this,'Title');
        if size(title,1)>1
            titleFactor=size(title,1)*0.9;
        end

        if size(strsplit(title,'\n'),2)>1
            titleFactor=size(strsplit(title,'\n'),2)*0.9;
        end

        if~isempty(title)
            insetFactor=4.1;
        else
            insetFactor=3.2;
        end
    elseif isCombinedViewMode(this)
        insetFactor=3.2;
    end

    set(this.Axes,'Units','pixels');
    if ispc
        pixInset=15*uiservices.getPixelFactor;
    else
        pixInset=(15+3)*uiservices.getPixelFactor;
    end
    colorBarOffsetFactor=1;
    if any(abs(this.Plotter.ColorLim)>1e4)
        colorBarOffsetFactor=1.4;
    end

    if isCombinedViewMode(this)&&strcmpi(getPropertyValue(this,'AxesLayout'),'Horizontal')
        set(this.Axes(1),'LooseInset',[pixInset,pixInset,pixInset,pixInset*insetFactor],'Units','normalized');
        set(this.Axes(2),'LooseInset',[pixInset,pixInset,pixInset,pixInset*insetFactor],'Units','normalized');
    else
        set(this.Axes(1),'LooseInset',[pixInset,pixInset,pixInset,pixInset],'Units','normalized');
        set(this.Axes(2),'LooseInset',[pixInset,pixInset,pixInset,colorBarOffsetFactor*pixInset*(insetFactor+titleFactor)],'Units','normalized');
    end
end
