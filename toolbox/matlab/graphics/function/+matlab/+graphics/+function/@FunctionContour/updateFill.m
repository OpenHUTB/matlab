function updateFill(hObj,updateState,data)



    if strcmp(hObj.FaceColorMode,'auto')
        hObj.FaceColor_I='flat';
    end

    [fillStrips,numFillStripsUsed]=initializeTriangleStrips(hObj.FacePrims);
    xdata=data.xdata;
    ydata=data.ydata;
    zdata=data.zdata;

    if strcmp(hObj.Fill,'on')&&~isempty(xdata)&&~isempty(ydata)&&~isempty(zdata)
        XYZPointsIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        hIndexColorsIter=matlab.graphics.axis.colorspace.IndexColorsIterator;

        levelList=[min(zdata),data.contourlines.Level];
        levels=[levelList,Inf];
        nfill=numel(levels)-1;
        cLevels=chooseColorLevels(levelList);
        for k=1:nfill
            lo=levels(k);
            hi=levels(k+1);

            s=matlab.graphics.chart.fillcontourinterval(xdata,ydata,zdata,lo,hi);

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

                setFillProperties(hTriStrip,hObj,cLevels(k),hIndexColorsIter,updateState.ColorSpace);
                hObj.addNode(hTriStrip);
            end
        end
        adjustFaceOffset(fillStrips)
    end
    hObj.FacePrims=cleanUpUnusedPrimitives(fillStrips,numFillStripsUsed);
end

function cLevels=chooseColorLevels(levelList)






    if numel(levelList)>1
        intervalWidth=diff(levelList);
        cLevels=levelList+intervalWidth([1:end,end])/100;
    else
        cLevels=levelList;
    end
end

function setFillProperties(hTriStrip,hObj,cdata,hIndexColorsIter,colorSpace)


    setFillColor(hTriStrip,hObj.FaceColor,...
    cdata,hIndexColorsIter,colorSpace)

    hTriStrip.HitTest='off';
    hTriStrip.Visible=hObj.Visible;
    hTriStrip.Parent=[];
end

function setFillColor(hFillPrimitive,faceColor,cdata,colorIter,colorSpace)

    if isequal(faceColor,'flat')||isequal(faceColor,'auto')
        colorIter.Colors=cdata;
        colorIter.CDataMapping='scaled';
        actualColor=colorSpace.TransformColormappedToTrueColor(colorIter);
        if~isempty(actualColor)
            hFillPrimitive.ColorData_I=actualColor.Data;
            hFillPrimitive.ColorType_I=actualColor.Type;
            hFillPrimitive.ColorBinding_I='object';
        else
            hFillPrimitive.ColorBinding_I='none';
        end
    else
        hgfilter('RGBAColorToGeometryPrimitive',hFillPrimitive,faceColor);
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
