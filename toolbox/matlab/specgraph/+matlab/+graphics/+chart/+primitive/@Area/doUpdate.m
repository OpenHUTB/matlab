function doUpdate(hObj,updateState)







    hObj.PrepWasAlreadyRun=false;

    updatedColor=hObj.getColor(updateState);
    if isequal(hObj.FaceColorMode,'auto')&&~isempty(updatedColor)
        hObj.FaceColor_I=updatedColor;
    end


    assert(numel(hObj.XDataCache)==numel(hObj.YDataCache),message('MATLAB:area:XDataSizeMismatch'));


    afc=hObj.FaceColor_I;
    aec=hObj.EdgeColor;
    cdata=hObj.CData;

    [faceVertices,faceStripData,edgeVertices,edgeStripData]=...
    createAreaVertexData(hObj,updateState.DataSpace,updateState.BaseValues(2));


    hFace=hObj.Face;
    hEdge=hObj.Edge;

    hFace.VertexData=[];
    hFace.StripData=[];
    hEdge.VertexData=[];
    hEdge.StripData=[];

    if isempty(faceVertices)||strcmp(hObj.Visible,'off')
        hFace.Visible='off';
    else
        hFace.Visible='on';
        iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
        iter.Vertices=faceVertices;
        vd=TransformPoints(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,iter);

        if size(vd,2)>=4
            hFace.VertexData=vd;
            hFace.StripData=uint32(faceStripData);
        end
    end

    if isempty(edgeVertices)||strcmp(hObj.Visible,'off')
        hEdge.Visible='off';
    else
        hEdge.Visible='on';
        iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
        iter.Vertices=edgeVertices;
        vd=TransformPoints(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,iter);


        if size(vd,2)>=2
            hEdge.VertexData=vd;
            hEdge.StripData=uint32(edgeStripData);
        end
    end


    hColorIter=matlab.graphics.axis.colorspace.IndexColorsIterator;
    hColorIter.CDataMapping=hObj.CDataMapping;

    if strcmp(afc,'flat')
        hColorIter.Colors=cdata;
        actualColor=updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);
        if~isempty(actualColor)
            hFace.ColorData_I=actualColor.Data;
            hFace.ColorType_I=actualColor.Type;
            hFace.ColorBinding_I='object';
        else
            hFace.ColorBinding_I='none';
        end
    else
        hgfilter('RGBAColorToGeometryPrimitive',hFace,afc);
    end

    if size(hFace.ColorData_I,1)==4&&~strcmp(afc,'none')
        hFace.ColorData_I(4,:)=uint8(255*hObj.FaceAlpha);
        if(hObj.FaceAlpha==1)
            hFace.ColorType_I='truecolor';
        else
            hFace.ColorType_I='truecoloralpha';
        end
    end


    if strcmp(aec,'flat')
        hColorIter.Colors=cdata;
        actualColor=updateState.ColorSpace.TransformColormappedToTrueColor(hColorIter);
        if~isempty(actualColor)
            hEdge.ColorData_I=actualColor.Data;
            hEdge.ColorType_I=actualColor.Type;
            hEdge.ColorBinding_I='object';
        else
            hEdge.ColorBinding_I='none';
        end
    else
        hgfilter('RGBAColorToGeometryPrimitive',hEdge,aec);
    end

    if size(hEdge.ColorData_I,1)==4&&~strcmp(aec,'none')
        hEdge.ColorData_I(4,:)=uint8(255*hObj.EdgeAlpha);
        if(hObj.EdgeAlpha==1)
            hEdge.ColorType_I='truecolor';
        else
            hEdge.ColorType_I='truecoloralpha';
        end
    end


    if~isempty(hObj.BrushHandles)
        hObj.BrushHandles.MarkDirty('all');
    end


    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
        if isempty(hObj.SelectionHandle)
            createSelectionHandle(hObj);
        end
        hObj.SelectionHandle.VertexData=hFace.VertexData;
        hObj.SelectionHandle.MaxNumPoints=300;
        hObj.SelectionHandle.Visible=hObj.Selected;
    else
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
            hObj.SelectionHandle.Visible='off';
        end
    end

end

function createSelectionHandle(hObj)


    hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
    hObj.addNode(hObj.SelectionHandle);


    hObj.SelectionHandle.Description='Area SelectionHandle';


    hObj.SelectionHandle.Clipping=hObj.Clipping;

end
