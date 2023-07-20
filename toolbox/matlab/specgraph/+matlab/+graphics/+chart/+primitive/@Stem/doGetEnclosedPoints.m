function I=doGetEnclosedPoints(hObj,polygon)






    vertexData=hObj.MarkerHandle.VertexData;
    pixelLocations=brushing.select.transformCameraToFigCoord(hObj,vertexData);
    Ivert=brushing.select.inpolygon(polygon,pixelLocations);


    if isempty(hObj.ZDataCache)
        markerData=[hObj.XDataCache;hObj.YDataCache];
    else
        markerData=[hObj.XDataCache;hObj.YDataCache;hObj.ZDataCache];
    end


    nonnanDataIndices=find(~any(isnan(markerData),1));
    I=nonnanDataIndices(Ivert);


