function[xData,yData]=getLineData(this,lineNum)



    hLines=getAllLines(this);
    if lineNum<=numel(hLines)
        hLine=hLines(lineNum);
        xData=get(hLine,'XData');
        yData=get(hLine,'YData');
    else

        xData=[];
        yData=[];
    end
end
