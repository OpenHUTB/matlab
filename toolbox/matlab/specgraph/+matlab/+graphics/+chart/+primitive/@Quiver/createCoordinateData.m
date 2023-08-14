function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)













    import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
    coordinateData=CoordinateData.empty(0,1);

    vertexPosition=hObj.getReportedPosition(dataIndex,0);
    location=vertexPosition.getLocation(hObj);

    switch(valueSource)
    case 'XData'
        coordinateData=CoordinateData(valueSource,location(1));
    case 'YData'
        coordinateData=CoordinateData(valueSource,location(2));
    case 'ZData'
        if vertexPosition.Is2D
            zVal=[];
        else
            zVal=location(3);
        end
        coordinateData=CoordinateData(valueSource,zVal);
    case '[XData,YData]'
        coordinateData=CoordinateData(valueSource,location);
    case '[XData,YData,ZData]'
        coordinateData=CoordinateData(valueSource,location);
    case 'UData'
        uVal=localComputeUVW(hObj,dataIndex,vertexPosition);
        coordinateData=CoordinateData(valueSource,uVal);
    case 'VData'
        [~,vVal]=localComputeUVW(hObj,dataIndex,vertexPosition);
        coordinateData=CoordinateData(valueSource,vVal);
    case 'WData'
        [~,~,wVal]=localComputeUVW(hObj,dataIndex,vertexPosition);
        coordinateData=CoordinateData(valueSource,wVal);
    case '[UData,VData]'
        [uVal,vVal]=localComputeUVW(hObj,dataIndex,vertexPosition);
        coordinateData=CoordinateData(valueSource,[uVal,vVal]);
    case '[UData,VData,WData]'
        [uVal,vVal,wVal]=localComputeUVW(hObj,dataIndex,vertexPosition);
        coordinateData=CoordinateData(valueSource,[uVal,vVal,wVal]);
    end
end

function[uVal,vVal,wVal]=localComputeUVW(hObj,dataIndex,vertexPosition)
    numPoints=numel(hObj.UData);
    if dataIndex>0&&dataIndex<=numPoints
        uVal=hObj.UData(dataIndex);
        vVal=hObj.VData(dataIndex);
        if~vertexPosition.Is2D
            wVal=hObj.WData(dataIndex);
        else
            wVal=0;
        end
    else
        uVal=NaN;
        vVal=NaN;
        wVal=NaN;
    end
end
