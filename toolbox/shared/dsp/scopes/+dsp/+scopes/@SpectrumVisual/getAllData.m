function[xData,yData]=getAllData(this,traceIndex)




    xData=[];
    yData=[];



    if isDataEmpty(this.Application.DataSource)||this.Application.screenMsg
        return;
    end

    hPlotter=this.Plotter;
    if~isCCDFMode(this)
        [xData,yData]=getLineData(hPlotter,traceIndex);
        if all(isnan(yData(:)))
            xData=[];
            yData=[];
        end
    else
        distTable=this.CurrentCCDFDistribution;
        if traceIndex<=numel(distTable)
            chanData=distTable{traceIndex};
            if size(chanData,1)>1
                xData=chanData(:,1);
                yData=chanData(:,2);
            end
        end
    end
end
