function doUpdate(hObj,updateState)




    xdata=hObj.XDataCache;
    ydata=hObj.YDataCache;
    zdata=hObj.ZDataCache;

    updatedColor=hObj.getColor(updateState);
    if isequal(hObj.ColorMode,'auto')&&~isempty(updatedColor)
        hObj.Color_I=updatedColor;
    end

    assert(numel(xdata)==numel(ydata),message('MATLAB:stem:XDataSizeMismatch'));


    if~isempty(zdata)
        assert(numel(zdata)==numel(xdata),message('MATLAB:stem3:ZDataSizeMismatch'));
    end
    updatedLineStyle=hObj.getLineStyle(updateState);
    if isequal(hObj.LineStyleMode,'auto')&&~isempty(updatedLineStyle)
        hObj.LineStyle_I=updatedLineStyle;
    end

    updatedMarker=hObj.getMarker(updateState);
    if isequal(hObj.MarkerMode,'auto')&&...
        ~isempty(updatedMarker)&&~strcmp(updatedMarker,'none')
        hObj.Marker_I=updatedMarker;
    end

    xdata=xdata(:);
    ydata=ydata(:);
    zdata=zdata(:);

    is3D=~isempty(zdata);
    if is3D
        baseValue=updateState.BaseValues(3);
    else
        baseValue=updateState.BaseValues(2);
    end

    xlen=length(xdata);
    ylen=length(ydata);
    zlen=length(zdata);

    if(is3D&&((xlen~=ylen)||(xlen~=zlen)))
        hObj.Edge.VertexData=[];
        hObj.MarkerHandle.VertexData=[];
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
        end
    elseif(~is3D&&(xlen~=ylen))
        hObj.Edge.VertexData=[];
        hObj.MarkerHandle.VertexData=[];
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
        end
    else

        xTmp=xdata;
        yTmp=ydata;
        zTmp=zdata;

        if is3D
            vIsNonFinite=~isfinite(xTmp)|~isfinite(yTmp)|~isfinite(zTmp);
            if isa(updateState.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
                vIsNonFinite=vIsNonFinite|matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.ZScale,updateState.DataSpace.ZLim,zTmp);
            end
            zdata=zTmp(~vIsNonFinite);
        else
            vIsNonFinite=~isfinite(xTmp)|~isfinite(yTmp);
            if isa(updateState.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
                invalid_x=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.XScale,updateState.DataSpace.XLim,xTmp);
                invalid_y=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.YScale,updateState.DataSpace.YLim,yTmp);
                vIsNonFinite=vIsNonFinite|invalid_x|invalid_y;
            end
        end
        xdata=xTmp(~vIsNonFinite);
        ydata=yTmp(~vIsNonFinite);

        numVert=length(xdata)*2;

        xx=zeros(numVert,1);
        xx(1:2:numVert)=xdata;
        xx(2:2:numVert)=xdata;

        if is3D
            yy=zeros(numVert,1);
            yy(1:2:numVert)=ydata;
            yy(2:2:numVert)=ydata;

            zz=baseValue*ones(numVert,1);
            zz(1:2:numVert)=zdata;
        else
            yy=baseValue*ones(numVert,1);
            yy(2:2:numVert)=ydata;
        end


        iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        iter.XData=xx;
        iter.YData=yy;
        if is3D
            iter.ZData=zz;
        end
        lineVertexData=TransformPoints(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,iter);

        if numVert<=1
            hObj.Edge.VertexData=[];
            hObj.Edge.StripData=[];
        else
            hObj.Edge.VertexData=lineVertexData;
            hObj.Edge.StripData=[];
        end

        if is3D
            hObj.MarkerHandle.VertexData=lineVertexData(:,1:2:numVert);
        else
            hObj.MarkerHandle.VertexData=lineVertexData(:,2:2:numVert);
        end


        mec=hObj.MarkerEdgeColor;
        if strcmpi(mec,'auto')
            mec=hObj.Color_I;
        end
        hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,mec);

        mfc=hObj.MarkerFaceColor;
        if strcmpi(mfc,'auto')
            mfc=mec;
        end
        hgfilter('FaceColorToMarkerPrimitive',hObj.MarkerHandle,mfc);

    end


    hObj.Edge.AlignVertexCenters='on';


    if~isempty(hObj.BrushHandles)
        hObj.BrushHandles.MarkDirty('all');
    end


    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
        if isempty(hObj.SelectionHandle)
            createSelectionHandle(hObj);
        end
        if numVert<=1
            hObj.SelectionHandle.VertexData=[];
        else

            hObj.SelectionHandle.VertexData=lineVertexData(:,union(1:4:numVert,2:4:numVert));
        end
        hObj.SelectionHandle.Visible=hObj.Selected;
    else
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
            hObj.SelectionHandle.Visible='off';
        end
    end

    updateDisplayNameBasedOnLabelHints(hObj,updateState.HintConsumer.getChannelDisplayNamesStruct);
end

function createSelectionHandle(hObj)

    hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
    hObj.addNode(hObj.SelectionHandle);


    hObj.SelectionHandle.Description='Stem SelectionHandle';


    hObj.SelectionHandle.Clipping=hObj.Clipping;
end
