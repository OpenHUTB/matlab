function I=doGetEnclosedPoints(hObj,polygon)







    n=length(hObj.XDataCache);
    IVertexData=hObj.MarkerHandle.VertexData;


    pixelMarkerLocations=brushing.select.transformCameraToFigCoord(hObj,IVertexData);


    IVertices=brushing.select.inpolygon(polygon,pixelMarkerLocations);


    markerData=[hObj.XDataCache;hObj.YDataCache];
    nonnanDataIndices=find(~any(isnan(markerData),1));


    I=false(n,1);
    I(nonnanDataIndices(IVertices))=true;




