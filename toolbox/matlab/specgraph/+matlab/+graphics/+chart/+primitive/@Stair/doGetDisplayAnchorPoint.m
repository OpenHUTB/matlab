function pt=doGetDisplayAnchorPoint(hObj,index,~)









    numPoints=numel(hObj.XDataCache);
    if index>0&&index<=numPoints
        pt=[double(hObj.XDataCache(index)),double(hObj.YDataCache(index)),0];
    else
        pt=[NaN,NaN,0];
    end
    pt=matlab.graphics.shape.internal.util.SimplePoint(pt);
