function doUpdate(hObj,updateState)




    updatedColor=hObj.getColor(updateState);
    if isequal(hObj.ColorMode,'auto')&&~isempty(updatedColor)
        hObj.Color_I=updatedColor;
    end

    updatedLineStyle=hObj.getLineStyle(updateState);
    if isequal(hObj.LineStyleMode,'auto')&&~isempty(updatedLineStyle)
        hObj.LineStyle_I=updatedLineStyle;
    end

    updatedMarker=hObj.getMarker(updateState);
    if isequal(hObj.MarkerMode,'auto')&&~isempty(updatedMarker)
        hObj.Marker_I=updatedMarker;
    end

    x=hObj.XDataCache;
    y=hObj.YDataCache;

    x=x(:);
    y=y(:);

    xlen=length(x);
    ylen=length(y);

    if(xlen~=ylen)
        hObj.Edge.VertexData=[];
        hObj.Edge.StripData=[];
        if~isempty(hObj.SelectionHandle)
            hObj.SelectionHandle.VertexData=[];
        end
    else
        [nr,nc]=size(y);
        ndx=[1:nr;1:nr];
        yy=y(ndx(1:2*nr-1),:);
        xx=x(ndx(2:2*nr),ones(1,nc));

        xTmp=xx;
        yTmp=yy;
        vIsNonFinite=~isfinite(xTmp)|~isfinite(yTmp);

        if isa(updateState.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
            invalid_x=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.XScale,updateState.DataSpace.XLim,xTmp);
            invalid_y=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.YScale,updateState.DataSpace.YLim,yTmp);
            vIsNonFinite(invalid_x|invalid_y)=true;
        end

        vIsNonFinitePad=[true;true;vIsNonFinite];
        sectionTrans=diff(diff(cumsum(~vIsNonFinitePad)));
        sectionNans=cumsum(vIsNonFinite);
        sectionBegins=find(sectionTrans==1);
        sectionBeginsNoNans=sectionBegins-sectionNans(sectionBegins);

        xx=xTmp(~vIsNonFinite);
        yy=yTmp(~vIsNonFinite);


        iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
        iter.XData=xx;
        iter.YData=yy;
        lineVertexData=TransformPoints(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,iter);

        numVert=numel(xx);


        if numVert<=1
            hObj.Edge.VertexData=[];
            hObj.Edge.StripData=[];
        else
            hObj.Edge.VertexData=lineVertexData;
            hObj.Edge.StripData=uint32([sectionBeginsNoNans',numVert+1]);
        end
        hObj.MarkerHandle.VertexData=lineVertexData(:,1:2:end);


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


    hObj.Edge.LineJoin='miter';


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
            hObj.SelectionHandle.VertexData=lineVertexData(:,1:2:end);
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


    hObj.SelectionHandle.Description='Stair SelectionHandle';


    hObj.SelectionHandle.Clipping=hObj.Clipping;
end
