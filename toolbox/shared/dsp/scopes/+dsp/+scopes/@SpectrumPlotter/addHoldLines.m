function hTraceLines=addHoldLines(this,hTraceLines,type)




    selectBehavior=uiservices.getPlotEditBehavior('select');
    lineNumberForColor=0;
    defaultColorOrder=this.ColorOrder;
    for indx=1:sum(this.NumberOfChannels)
        lineNumberForColor=lineNumberForColor+1;
        lc=defaultColorOrder(rem(lineNumberForColor-1,size(defaultColorOrder,1))+1,:);
        if strcmp(type,'Max')
            nc=this.MaxLineColorMultiplier*lc;
        else
            nc=this.MinLineColorMultiplier*lc;
        end
        if length(hTraceLines)<indx||~ishghandle(hTraceLines(indx))
            hTraceLines(indx)=line(0,NaN,'Parent',this.Axes(1,1));
            hgaddbehavior(hTraceLines(indx),selectBehavior);
            set(hTraceLines(indx),'Color',nc);
        else
            set(hTraceLines(indx),'XData',[],'YData',[]);
        end
    end
end
