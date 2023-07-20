function[xData,yData]=getVisibleData(this,traceIndex)




    [xData,yData]=getLineData(this.Plotter,traceIndex);
    if~isempty(xData)&&~isDataEmpty(this.Application.DataSource)&&~this.Application.screenMsg

        xlim=get(this.Axes(1,1),'XLim');
        iLower=find(xData>=xlim(1),1,'first');
        iUpper=find(xData<=xlim(2),1,'last');

        if~isempty(iUpper)&&iUpper>2&&xData(iUpper)==xData(iUpper-1)
            iUpper=iUpper-1;
        end
        xData=xData(iLower:iUpper);
        yData=yData(iLower:iUpper);
    else



        xData=[];
        yData=[];
    end
end
