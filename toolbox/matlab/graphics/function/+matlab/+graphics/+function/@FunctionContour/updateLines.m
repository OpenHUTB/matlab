function updateLines(hObj,us,data)



    contourLines=data.contourlines;

    [lineStrips,numLineStripsUsed]=initializeLineStrips(hObj.Edge);

    hXYZPointsIter=matlab.graphics.axis.dataspace.XYZPointsIterator;
    hIndexColorsIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
    for k=1:numel(contourLines)
        contourLine=contourLines(k);
        hXYZPointsIter.XData=contourLine.VertexData(1,:);
        hXYZPointsIter.YData=contourLine.VertexData(2,:);
        hXYZPointsIter.ZData=contourLine.VertexData(3,:);

        lineVertexData=TransformPoints(us.DataSpace,...
        us.TransformUnderDataSpace,hXYZPointsIter);

        [hLineStrip,lineStrips,numLineStripsUsed]...
        =nextLineStrip(lineStrips,numLineStripsUsed);

        hLineStrip.VertexData=lineVertexData;
        hLineStrip.StripData=uint32(contourLine.StripData);

        cdata=contourLine.Level;
        setLineProperties(hLineStrip,hObj,cdata,hIndexColorsIter,us.ColorSpace);
        hObj.addNode(hLineStrip);
    end
    hObj.Edge=cleanUpUnusedPrimitives(lineStrips,numLineStripsUsed);


    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
        if isempty(hObj.SelectionHandle)
            createSelectionHandle(hObj);
        end
        hObj.SelectionHandle.VertexData=horzcat(hObj.Edge.VertexData);
        hObj.SelectionHandle.Visible='on';
    else
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
            hObj.SelectionHandle.Visible='off';
        end
    end
end

function[lineStrips,numLineStripsUsed]=initializeLineStrips(lineStrips)
    numLineStripsUsed=0;
    if isempty(lineStrips)
        lineStrips=matlab.graphics.primitive.world.LineStrip.empty;
    end
end

function[nextStrip,lineStrips,numLineStripsUsed]=nextLineStrip(lineStrips,numLineStripsUsed)
    if numLineStripsUsed<length(lineStrips)
        nextStrip=lineStrips(numLineStripsUsed+1);
    else
        nextStrip=matlab.graphics.primitive.world.LineStrip('Internal',true);
        lineStrips=[lineStrips;nextStrip];
    end
    numLineStripsUsed=numLineStripsUsed+1;
end

function strips=cleanUpUnusedPrimitives(strips,numStripsUsed)
    numPrims=numel(strips);
    if numStripsUsed<numPrims
        unused=(numStripsUsed+1):numPrims;
        delete(strips(unused))
        strips(unused)=[];
    end
end

function setLineProperties(hLineStrip,hObj,cdata,hIndexColorsIter,colorSpace)


    setLineColor(hLineStrip,hObj.LineColor,cdata,hIndexColorsIter,colorSpace)

    hgfilter('LineStyleToPrimLineStyle',hLineStrip,hObj.LineStyle);

    hLineStrip.HitTest='off';
    hLineStrip.LineWidth=hObj.LineWidth;
    hLineStrip.Visible=hObj.Visible;
    hLineStrip.Parent=[];
end

function setLineColor(hLinePrimitive,lineColor,cdata,colorIter,colorSpace)
    if isequal(lineColor,'flat')||isequal(lineColor,'auto')
        colorIter.Colors=cdata;
        colorIter.CDataMapping='scaled';
        actualColor=colorSpace.TransformColormappedToTrueColor(colorIter);
        if~isempty(actualColor)
            hLinePrimitive.ColorData_I=actualColor.Data;
            hLinePrimitive.ColorType_I=actualColor.Type;
            hLinePrimitive.ColorBinding_I='object';
        else
            hLinePrimitive.ColorBinding_I='none';
        end
    else
        hgfilter('RGBAColorToGeometryPrimitive',hLinePrimitive,lineColor);
    end
end
