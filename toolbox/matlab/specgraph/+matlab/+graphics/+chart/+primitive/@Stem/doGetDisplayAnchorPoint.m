function pt=doGetDisplayAnchorPoint(hObj,index,~)









    numPoints=numel(hObj.XDataCache);
    if index>0&&index<=numPoints
        zVal=0;
        zData=hObj.ZDataCache;
        if~isempty(zData)
            zVal=hObj.ZDataCache(index);
        end
        pt=[double(hObj.XDataCache(index)),double(hObj.YDataCache(index)),double(zVal)];
    else
        pt=[NaN,NaN,NaN];
    end
    pt=matlab.graphics.shape.internal.util.SimplePoint(pt);