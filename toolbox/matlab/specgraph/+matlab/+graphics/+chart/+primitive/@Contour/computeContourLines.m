function contourLines=computeContourLines(hObj,updateState,linkStrips)












    import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale

    if nargin<3
        linkStrips=true;
    end

    xdata=getXDataImpl(hObj);
    ydata=getYDataImpl(hObj);
    zdata=hObj.ZData;
    levelList=getLevelListImpl(hObj);
    validContourZLevel=true;
    if(nargin>1&&~isempty(updateState))
        hDataSpace=updateState.DataSpace;
        validContourZLevel=hObj.Is3D||...
        ~isa(hDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')...
        ||strcmp(hDataSpace.ZScale,'linear')...
        ||~isInvalidInLogScale('log',hDataSpace.ZLim,hObj.ContourZLevel);

        [xdata,ydata,levelList]=matlab.graphics.chart.primitive.Contour.checkOutOfRangeVertices(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,...
        xdata,ydata,...
        levelList,hObj.Is3D);
    end
    if validContourZLevel
        contourLines=contourXYZData(hObj,xdata,ydata,zdata,levelList,linkStrips);
        contourLines=adjustZCoordinates(hObj,contourLines);
    else
        contourLines=matlab.graphics.chart.internal.contour.ContourLine.empty();
    end
end

function contourLines=contourXYZData(hObj,xdata,ydata,zdata,levelList,linkStrips)
    if~isempty(xdata)&&~isempty(ydata)&&~isempty(zdata)
        if isvector(xdata)&&isvector(ydata)
            [xdata,ydata]=meshgrid(xdata,ydata);
        end

        if isequal(size(zdata),size(xdata),size(ydata))
            needFill=~strcmp(hObj.FaceColor,'none');
            cache=hObj.getContourDataCache();
            cache.validateCache(xdata,ydata,zdata);
            contourLines=cache.getContourLines(levelList,linkStrips,needFill);
        else
            contourLines=matlab.graphics.chart.internal.contour.ContourLine.empty();
        end
    else
        contourLines=matlab.graphics.chart.internal.contour.ContourLine.empty();
    end
end

function contourLines=adjustZCoordinates(hObj,contourLines)
    plotIs3D=strcmp(hObj.Is3D,'on');
    for k=1:numel(contourLines)
        if plotIs3D
            contourLines(k).VertexData(3,:)=contourLines(k).Level;
        else
            contourLines(k).VertexData(3,:)=hObj.ContourZLevel;
        end
    end
end

