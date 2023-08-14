function I=doGetEnclosedPoints(hObj,polygon)





    markerOrder=hObj.MarkerOrder;
    numMarkers=numel(hObj.XData_I);

    vertexData=hObj.MarkerHandle.VertexData;

    if strcmp(hObj.MarkerHandleNaN.Visible,'on')
        vertexData=[vertexData,hObj.MarkerHandleNaN.VertexData];
    end


    pixelTopLocations=brushing.select.transformCameraToFigCoord(hObj,vertexData);


    Ivertices=brushing.select.inpolygon(polygon,pixelTopLocations);

    I=false(numMarkers,1);
    I(markerOrder(Ivertices))=true;





