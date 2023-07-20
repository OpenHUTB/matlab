function pt=doGetDisplayAnchorPoint(hObj,index,~)







    numPoints=numel(hObj.XDataCache);
    if index>0&&index<=numPoints
        zVal=0;
        zData=hObj.ZDataCache;
        if~isempty(zData)
            zVal=hObj.ZDataCache(index);
        end
        if any(~strcmp({hObj.XJitter,hObj.YJitter,hObj.XJitter},'none'))
            pt=double(hObj.XYZJittered(index,:));
        else
            pt=[double(hObj.XDataCache(index)),double(hObj.YDataCache(index)),double(zVal)];
        end
    else
        pt=[NaN,NaN,NaN];
    end
    pt=matlab.graphics.shape.internal.util.SimplePoint(pt);

