function doUpdate(hObj,updateState)



    [x,y,sd,xb,yb,vinds,hinds]=createErrorBarVertices(hObj,updateState.DataSpace);


    numPoints=numel(y);
    iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
    iter.XData=x;
    iter.YData=y;
    vd=TransformPoints(updateState.DataSpace,...
    updateState.TransformUnderDataSpace,iter);


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


    if numPoints<=1
        hObj.Line.VertexData=[];
        hObj.Line.StripData=[];
        hObj.SelectionHandle.VertexData=[];
    else
        hObj.Line.VertexData=vd;
        hObj.Line.StripData=sd;
        hObj.SelectionHandle.VertexData=vd;
    end
    hObj.MarkerHandle.VertexData=vd;


    tform=updateState.TransformUnderDataSpace;

    if strcmpi(updateState.DataSpace.isLinear,'on')




        iter.Resetpoint;
        iter.XData=xb;
        iter.YData=yb;

        barVertexData=TransformPoints(updateState.DataSpace,tform,iter);
        barVertexIndices=[hinds(:);vinds(:)]';
        barStripData=zeros(1,0,'uint32');
    else





        barVertexData=zeros(3,0,'single');
        barVertexIndices=zeros(1,0,'uint32');
        barStripData=ones(1,1,'uint32');

        for p=1:size(hinds,2)
            coords=[xb(hinds(:,p))',yb(hinds(:,p))',[0;0]];
            vd=TransformLine(updateState.DataSpace,tform,coords);
            barVertexData=[barVertexData,single(vd)];%#ok<AGROW>
            barStripData=[barStripData,barStripData(end)+size(vd,2)];%#ok<AGROW>
            hinds(2,p)=barStripData(end)-1;
        end
        for p=1:size(vinds,2)
            coords=[xb(vinds(:,p))',yb(vinds(:,p))',[0;0]];
            vd=TransformLine(updateState.DataSpace,tform,coords);
            barVertexData=[barVertexData,single(vd)];%#ok<AGROW>
            barStripData=[barStripData,barStripData(end)+size(vd,2)];%#ok<AGROW>
            vinds(2,p)=barStripData(end)-1;
        end
    end



    if isempty(barVertexIndices)&&isempty(barStripData)
        hObj.Bar.VertexData=[];
    else
        hObj.Bar.VertexData=barVertexData;
    end
    hObj.Bar.VertexIndices=barVertexIndices;
    hObj.Bar.StripData=barStripData;


    if hObj.CapSize>0
        if isempty(vinds)
            hObj.Cap.Visible='off';
        else
            hObj.Cap.VertexData=barVertexData(:,vinds(2,:));
            hObj.Cap.Size=hObj.CapSize;
            hObj.Cap.Style='hbar';
            hObj.Cap.Visible='on';
        end
        if isempty(hinds)
            hObj.CapH.Visible='off';
        else
            hObj.CapH.VertexData=barVertexData(:,hinds(2,:));
            hObj.CapH.Size=hObj.CapSize;
            hObj.CapH.Style='vbar';
            hObj.CapH.Visible='on';
        end
    else
        hObj.Cap.Visible='off';
        hObj.CapH.Visible='off';
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


    hObj.Bar.AlignVertexCenters='on';


    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
        hObj.SelectionHandle.Visible='on';
    else
        hObj.SelectionHandle.Visible='off';
    end
