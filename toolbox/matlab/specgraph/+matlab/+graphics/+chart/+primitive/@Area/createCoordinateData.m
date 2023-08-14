function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,interpolationFactor)














    import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
    coordinateData=CoordinateData.empty(0,1);
    if nargin<4
        interpolationFactor=0;
    end

    reportedPosition=hObj.getReportedPosition(dataIndex,interpolationFactor);
    location=reportedPosition.getLocation(hObj);


    [xLoc,yLoc]=matlab.graphics.internal.makeNonNumeric(hObj,location(1),location(2));

    dimensionNames=hObj.DimensionNames;
    xDataSource=[dimensionNames{1},'Data'];
    yDataSource=[dimensionNames{2},'Data'];


    if hObj.NumPeers>1

        primstackedpos=getDisplayAnchorPoint(hObj,dataIndex,0);
        stackedLocation=primstackedpos.getLocation(hObj);

        [xStackedLoc,yStackedLoc]=matlab.graphics.internal.makeNonNumeric(hObj,stackedLocation(1),stackedLocation(2));


        switch(valueSource)
        case xDataSource
            coordinateData=CoordinateData(valueSource,xStackedLoc);
        case 'Y (Stacked)'
            coordinateData=CoordinateData(valueSource,yStackedLoc);
        case 'Y (Segment)'
            coordinateData=CoordinateData(valueSource,yLoc);
        end
    else
        switch(valueSource)
        case xDataSource
            coordinateData=CoordinateData(valueSource,xLoc);
        case yDataSource
            coordinateData=CoordinateData(valueSource,yLoc);
        end
    end