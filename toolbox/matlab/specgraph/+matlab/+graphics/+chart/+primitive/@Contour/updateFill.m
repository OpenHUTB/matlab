function updateFill(hObj,updateState)




    import matlab.graphics.chart.primitive.utilities.isInvalidInLogScale

    [fillStrips,numFillStripsUsed]=initializeTriangleStrips(hObj.FacePrims);
    xdata=getXDataImpl(hObj);
    ydata=getYDataImpl(hObj);
    [xdata,ydata]=matlab.graphics.chart.primitive.Contour.checkOutOfRangeVertices(updateState.DataSpace,...
    updateState.TransformUnderDataSpace,...
    xdata,ydata,[],false);
    zdata=hObj.ZData;


    if isvector(xdata)&&isvector(ydata)
        [xdata,ydata]=meshgrid(xdata,ydata);
    end



    if isvector(xdata)||isvector(ydata)||...
        (size(xdata,2)~=size(zdata,2)&&size(ydata,1)~=size(zdata,1))
        warning(message('MATLAB:contour:LengthOfXandYMustMatchColsAndRowsInZ'));
    elseif size(xdata,2)~=size(zdata,2)
        warning(message('MATLAB:contour:LengthOfXMustMatchColsInZ'));
    elseif size(ydata,1)~=size(zdata,1)
        warning(message('MATLAB:contour:LengthOfYMustMatchRowsInZ'));
    end

    hDataSpace=updateState.DataSpace;
    validContourZLevel=~isa(hDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')...
    ||strcmp(hDataSpace.ZScale,'linear')...
    ||~isInvalidInLogScale('log',hDataSpace.ZLim,hObj.ContourZLevel);

    if~strcmp(hObj.FaceColor,'none')...
        &&~isempty(xdata)&&~isempty(ydata)&&~isempty(zdata)...
        &&isequal(size(zdata),size(xdata),size(ydata))...
        &&validContourZLevel
        XYZPointsIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        hIndexColorsIter=matlab.graphics.axis.colorspace.IndexColorsIterator;

        levelList=getLevelListImpl(hObj);
        levels=[levelList,Inf];
        nfill=numel(levels)-1;
        cLevels=chooseColorLevels(levelList);
        cache=hObj.getContourDataCache();
        cache.validateCache(xdata,ydata,zdata);
        for k=1:nfill
            lo=levels(k);
            hi=levels(k+1);

            s=cache.getContourFillData(lo,hi);

            if~isempty(s)
                XYZPointsIter.XData=s.TriangleVertices(1,:);
                XYZPointsIter.YData=s.TriangleVertices(2,:);
                XYZPointsIter.ZData=hObj.ContourZLevel...
                +zeros(size(XYZPointsIter.XData),'like',XYZPointsIter.XData);

                fillVertexData=TransformPoints(updateState.DataSpace,...
                updateState.TransformUnderDataSpace,XYZPointsIter);
                fillStripData=uint32(s.TriangleStripData);

                [hTriStrip,fillStrips,numFillStripsUsed]...
                =nextTriangleStrip(fillStrips,numFillStripsUsed);

                hTriStrip.VertexData=fillVertexData;
                hTriStrip.StripData=fillStripData;

                setFillProperties(hTriStrip,hObj,cLevels(k),hIndexColorsIter,updateState.ColorSpace)
                hObj.addNode(hTriStrip);
            end
        end
        adjustFaceOffset(fillStrips)
    end
    hObj.FacePrims_I=cleanUpUnusedPrimitives(fillStrips,numFillStripsUsed);
end

function cLevels=chooseColorLevels(levelList)






    finiteValues=isfinite(levelList);
    cLevels=levelList;

    if numel(levelList(finiteValues))>1
        intervalWidth=diff(levelList(finiteValues));
        cLevels(finiteValues)=levelList(finiteValues)+intervalWidth([1:end,end])/100;
    end
end

function setFillProperties(hTriStrip,hObj,cdata,hIndexColorsIter,colorSpace)


    setFillColor(hTriStrip,hObj.FaceColor,...
    cdata,hIndexColorsIter,colorSpace,hObj.FaceAlpha)

    hTriStrip.HitTest='off';
    hTriStrip.Visible=hObj.Visible;
    hTriStrip.Parent=[];
end

function setFillColor(hFillPrimitive,faceColor,cdata,colorIter,colorSpace,alphadata)

    if isequal(faceColor,'flat')||isequal(faceColor,'auto')
        colorIter.Colors=cdata;
        colorIter.CDataMapping='scaled';
        colorIter.AlphaData=alphadata;
        colorIter.AlphaDataMapping='none';
        actualColor=colorSpace.TransformColormappedToTrueColor(colorIter);
        if~isempty(actualColor)
            hFillPrimitive.ColorData_I=actualColor.Data;
            hFillPrimitive.ColorType_I=actualColor.Type;
            hFillPrimitive.ColorBinding_I='object';
        else
            hFillPrimitive.ColorBinding_I='none';
        end
    elseif isequal(faceColor,'none')
        hgfilter('RGBAColorToGeometryPrimitive',hFillPrimitive,faceColor);
    else
        hgfilter('RGBAColorToGeometryPrimitive',hFillPrimitive,[faceColor,alphadata]);
    end
end

function adjustFaceOffset(fillStrips)
    n=length(fillStrips);
    if n>1
        for k=1:n
            fillStrips(k).FaceOffsetFactor=0;
            fillStrips(k).FaceOffsetBias=(1e-3)+(n-k)/(n-1)/30;
        end
    end
end

function[triStrips,numTriStripsUsed]=initializeTriangleStrips(triStrips)
    numTriStripsUsed=0;
    if isempty(triStrips)
        triStrips=matlab.graphics.primitive.world.TriangleStrip.empty;
    end
end

function[nextStrip,triStrips,numTriStripsUsed]=nextTriangleStrip(triStrips,numTriStripsUsed)
    if numTriStripsUsed<length(triStrips)
        nextStrip=triStrips(numTriStripsUsed+1);
    else
        nextStrip=matlab.graphics.primitive.world.TriangleStrip('Internal',true);
        triStrips=[triStrips;nextStrip];
    end
    numTriStripsUsed=numTriStripsUsed+1;
end

function strips=cleanUpUnusedPrimitives(strips,numStripsUsed)
    numPrims=numel(strips);
    if numStripsUsed<numPrims
        unused=(numStripsUsed+1):numPrims;
        delete(strips(unused))
        strips(unused)=[];
    end
end
