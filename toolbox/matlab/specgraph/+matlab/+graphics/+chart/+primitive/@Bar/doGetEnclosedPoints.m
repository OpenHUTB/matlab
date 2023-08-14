function I=doGetEnclosedPoints(hObj,polygon)





    barOrder=hObj.BarOrder;
    numBars=numel(barOrder);



    grid=(0:(numBars-1))*4;

    ItopVertexIndices=[2+grid;3+grid];


    topVertices=hObj.Edge.VertexData(:,ItopVertexIndices(:));


    pixelTopLocations=brushing.select.transformCameraToFigCoord(hObj,topVertices);


    Ivertices=brushing.select.inpolygon(polygon,pixelTopLocations);



    Ivalid=false(numBars,1);
    selectedData=floor((1+Ivertices)/2);
    Ivalid(selectedData)=true;

    I=false(numBars,1);
    I(barOrder)=Ivalid;
