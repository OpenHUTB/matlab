function pt=doGetDisplayAnchorPoint(hObj,index,~)










    numPoints=numel(hObj.XDataCache);
    if index>0&&index<=numPoints


        xData=double(hObj.XDataCache(index));
        xData=xData+hObj.XOffset;

        yData=double(hObj.YDataCache(index));
        if isnan(yData)

            yData=0;
        end
        yOffset=hObj.YOffset;
        if~isempty(yOffset)
            yData=yData+double(yOffset(index));
        end


        if strcmpi(hObj.Horizontal,'on')
            pt=[yData,xData,0];
        else
            pt=[xData,yData,0];
        end
    else
        pt=[NaN,NaN,0];
    end

    pt=matlab.graphics.shape.internal.util.SimplePoint(pt);
