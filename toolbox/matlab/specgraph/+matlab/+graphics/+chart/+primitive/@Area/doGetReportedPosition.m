function ret=doGetReportedPosition(hObj,index,~)








    numPoints=numel(hObj.YDataCache);
    if numel(hObj.XDataCache)~=numPoints
        pt=[NaN,NaN,0];
    elseif index>0&&index<=numPoints
        x=hObj.XDataCache(index);
        y=hObj.YDataCache(index);
        pt=[double(x),double(y),0];
    else
        pt=[NaN,NaN,0];
    end
    pt=matlab.graphics.shape.internal.util.SimplePoint(pt);
    pt.Is2D=true;
    ret=pt;
