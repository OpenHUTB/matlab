function prepareForPrinter(this,printFig)





    oldColorOrder=uiscopes.getColorOrder([0,0,0]);
    newColorOrder=uiscopes.getColorOrder([1,1,1]);

    hAxes=findall(printFig,'Tag','VisualAxes');
    if isempty(hAxes)
        return

    end


    printBackgroundColor=[1,1,1];
    printTickColor=[0,0,0];
    set(hAxes,'Color',printBackgroundColor);
    set(hAxes,'XColor',printTickColor,'YColor',printTickColor);
    hYLabel=get(hAxes,'YLabel');
    hXLabel=get(hAxes,'XLabel');
    if~isCombinedViewMode(this)
        set([hYLabel;hXLabel],'Color',printTickColor);
    else
        set([hYLabel{1,1};hXLabel{1,1}],'Color',printTickColor);
        set([hYLabel{2,1};hXLabel{2,1}],'Color',printTickColor);
    end

    hTit=get(hAxes(1,1),'Title');
    set(hTit,'Color',printTickColor);

    hTextReadout=findall(printFig,'Tag','StatusBarReadoutText');
    if ishghandle(hTextReadout)
        set(hTextReadout,'Color',printTickColor);
    end

    if isSpectrogramMode(this)
        hColorbar=findall(printFig,'Tag','Colorbar');
        if ishghandle(hColorbar)
            set(hColorbar,'XColor',printTickColor);
        end
    end

    if isCCDFMode(this)||(~isSpectrogramMode(this)&&...
        ~getPropertyValue(this,'MinHoldTrace')&&...
        ~getPropertyValue(this,'MaxHoldTrace'))
        for jndx=1:numel(this.Lines)
            lineTag=sprintf('DisplayLine%d',jndx);

            hLine=findall(hAxes,'Tag',lineTag);

            oldIndex=rem(jndx-1,size(oldColorOrder,1))+1;
            newIndex=rem(jndx-1,size(newColorOrder,1))+1;

            if isequal(get(hLine,'Color'),oldColorOrder(oldIndex,:))
                set(hLine,'Color',newColorOrder(newIndex,:));
            end
        end
    end
end
