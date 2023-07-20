function coordinateData=createCoordinateData(hObj,valueSource,index,~)





    import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
    coordinateData=CoordinateData.empty(0,1);


    gStats=hObj.GroupStatistics;

    ngrp=hObj.XNumGroups;
    xind=index;
    if index>ngrp
        xind=find((cumsum(gStats.NumOutliers)-(index-ngrp))>=0);
        xind=xind(1);
    end

    switch(valueSource)
    case getString(message('MATLAB:graphics:boxchart:Position'))
        coordinateData=CoordinateData(valueSource,hObj.XGroupNames(xind));
    case getString(message('MATLAB:graphics:boxchart:NumPoints'))
        coordinateData=CoordinateData(valueSource,gStats.NumPoints(xind));
    case getString(message('MATLAB:graphics:boxchart:NumOutliers'))
        coordinateData=CoordinateData(valueSource,gStats.NumOutliers(xind));
    case getString(message('MATLAB:graphics:boxchart:Median'))
        coordinateData=CoordinateData(valueSource,gStats.Median(xind));
    case getString(message('MATLAB:graphics:boxchart:Quartiles'))
        coordinateData=CoordinateData(valueSource,[gStats.BoxLower(xind),gStats.BoxUpper(xind)]);
    case getString(message('MATLAB:graphics:boxchart:Whiskers'))
        coordinateData=CoordinateData(valueSource,[gStats.WhiskerLower(xind),gStats.WhiskerUpper(xind)]);
    case getString(message('MATLAB:graphics:boxchart:Notches'))
        coordinateData=CoordinateData(valueSource,gStats.Notch(:,xind)');
    case getString(message('MATLAB:graphics:boxchart:ColorGroup'))
        coordinateData=CoordinateData(valueSource,hObj.DisplayName);
    case getString(message('MATLAB:graphics:boxchart:OutlierValue'))
        bydata=[];
        if index>ngrp

            verts=hObj.OutlierVertexData;
            isvert=strcmpi(hObj.Orientation_I,'vertical');
            bydata=verts(index-ngrp,1+isvert);
        end
        coordinateData=CoordinateData(valueSource,bydata);
    end
end