function setupNormalTraceLines(this,plotTypeChanged)



    nChannels=sum(this.NumberOfChannels);

    hLines=this.Lines;
    delete(hLines(nChannels+1:end));
    hLines(nChannels+1:end)=[];
    selectBehavior=uiservices.getPlotEditBehavior('select');
    defaultProps=getDefaultLineProperties(this);
    defaultColorOrder=this.ColorOrder;
    plotType=lower(this.PlotType);
    lineNumberForColor=0;
    for indx=1:nChannels
        lineNumberForColor=lineNumberForColor+1;


        if length(hLines)<indx||~ishghandle(hLines(indx))||plotTypeChanged
            hLines(indx)=feval(plotType,0,NaN,...
            'Tag',sprintf('DisplayLine%d',indx),'Parent',this.Axes(1,1));
            defaultProps.Color=defaultColorOrder(...
            rem(lineNumberForColor-1,size(defaultColorOrder,1))+1,:);
            set(hLines(indx),defaultProps);
            hgaddbehavior(hLines(indx),selectBehavior);
            if plotTypeChanged
                delete(this.Lines(indx));
            end
        else
            set(hLines(indx),'XData',[],'YData',[]);
        end
    end
    this.Lines=hLines;
end
