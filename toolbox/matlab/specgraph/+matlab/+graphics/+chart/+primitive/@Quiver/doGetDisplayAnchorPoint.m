function pt=doGetDisplayAnchorPoint(hObj,index,~)










    numPoints=numel(hObj.UData);
    if index>0&&index<=numPoints
        xIndex=index;
        yIndex=index;
        xData=hObj.XData;
        yData=hObj.YData;
        dataSize=size(hObj.UData);
        if~isequal(size(xData),dataSize)
            [~,xIndex]=ind2sub(dataSize,index);
        end
        if~isequal(size(yData),dataSize)
            [yIndex,~]=ind2sub(dataSize,index);
        end


        zVal=0;
        zData=hObj.ZData;
        if~isempty(zData)
            zVal=hObj.ZData(index);
        end
        pt=[double(xData(xIndex)),double(yData(yIndex)),double(zVal)];
    else
        pt=[NaN,NaN,NaN];
    end
    pt=matlab.graphics.shape.internal.util.SimplePoint(pt);
