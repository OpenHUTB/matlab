function doUpdate(hObj,updateState)







    if isempty(hObj.UData)||isempty(hObj.VData)
        return
    end

    updatedColor=hObj.getColor(updateState);
    if isequal(hObj.ColorMode,'auto')&&~isempty(updatedColor)
        hObj.Color_I=updatedColor;
    end

    updatedLineStyle=hObj.getLineStyle(updateState);
    if isequal(hObj.LineStyleMode,'auto')&&~isempty(updatedLineStyle)
        hObj.LineStyle_I=updatedLineStyle;
    end


    [x,y,z,u,v,w,msg]=hObj.preProcessData;


    if isa(updateState.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
        invalid_x=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.XScale,updateState.DataSpace.XLim,x);
        invalid_y=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.YScale,updateState.DataSpace.YLim,y);
        x(invalid_x)=NaN;
        y(invalid_y)=NaN;

        if hObj.is3D
            invalid_z=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(updateState.DataSpace.ZScale,updateState.DataSpace.ZLim,z);
            z(invalid_z)=NaN;
        end
    end


    nani=isfinite(x(:))&isfinite(y(:))&isfinite(z(:))&isfinite(u(:))&isfinite(v(:))&isfinite(w(:));
    x=x(nani);
    y=y(nani);
    z=z(nani);
    u=u(nani);
    v=v(nani);
    w=w(nani);


    if~isempty(msg)||isempty(x)||isempty(y)||isempty(u)||isempty(v)
        set(hObj.MarkerHandle,'Visible','off');
        set(hObj.Tail,'Visible','off');
        set(hObj.Head,'Visible','off');
        if~isempty(msg)
            warning(msg.identifier,msg.message);
        end
        return
    end


    iter=matlab.graphics.axis.dataspace.XYZPointsIterator;

    if~isempty(hObj.MarkerHandle)&&isvalid(hObj.MarkerHandle)
        set(hObj.MarkerHandle,'Visible','on');
        markerVData=calculateMarkerVertexData(hObj,hObj.is3D,x,y,z);
        iter.XData=markerVData(:,1);
        iter.YData=markerVData(:,2);
        if hObj.is3D
            iter.ZData=markerVData(:,3);
        end
        transformedMarkerVData=TransformPoints(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,iter);
        set(hObj.MarkerHandle,'VertexData',transformedMarkerVData);


        mec=hObj.MarkerEdgeColor;
        if strcmpi(mec,'auto')
            hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,hObj.Color_I);
        elseif strcmpi(mec,'none')
            hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,'none');
        else
            hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,mec);
        end

        mfc=hObj.MarkerFaceColor;
        if strcmpi(mfc,'auto')||strcmpi(mfc,'none')
            hgfilter('FaceColorToMarkerPrimitive',hObj.MarkerHandle,'none');
        else
            hgfilter('FaceColorToMarkerPrimitive',hObj.MarkerHandle,mfc);
        end

    end

    offset=hObj.getAlignmentOffset();
    vd=[];
    if~isempty(hObj.Tail)&&isvalid(hObj.Tail)
        set(hObj.Tail,'Visible','on');
        tailVData=calculateTailVertexData(hObj,hObj.is3D,x,y,z,u,v,w,offset);
        iter.XData=tailVData(:,1);
        iter.YData=tailVData(:,2);
        if hObj.is3D
            iter.ZData=tailVData(:,3);
        end
        transformedTailVData=TransformPoints(updateState.DataSpace,...
        updateState.TransformUnderDataSpace,iter);
        set(hObj.Tail,'VertexData',transformedTailVData);
        set(hObj.Tail,'StripData',uint32(1:2:size(tailVData,1)+1));
        vd=[vd,transformedTailVData];
    end


    if~isempty(hObj.Head)&&isvalid(hObj.Head)
        if strcmp(hObj.ShowArrowHead,'on')
            set(hObj.Head,'Visible','on');
            headVData=calculateHeadVertexData(hObj,hObj.is3D,x,y,z,u,v,w,offset);
            iter.XData=headVData(:,1);
            iter.YData=headVData(:,2);
            if hObj.is3D
                iter.ZData=headVData(:,3);
            end
            transformedHeadVData=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,iter);
            set(hObj.Head,'VertexData',transformedHeadVData);
            set(hObj.Head,'StripData',uint32(1:3:size(headVData,1)+1));
            vd=[vd,transformedHeadVData];
        else
            set(hObj.Head,'Visible','off');
        end
    end


    xminvd=min(vd(1,:));
    xmaxvd=max(vd(1,:));
    yminvd=min(vd(2,:));
    ymaxvd=max(vd(2,:));
    zminvd=min(vd(3,:));
    zmaxvd=max(vd(3,:));
    if zminvd==zmaxvd
        hObj.SelectionHandle.VertexData=...
        [xminvd,xminvd,xmaxvd,xmaxvd;
        yminvd,ymaxvd,yminvd,ymaxvd;
        zminvd,zminvd,zminvd,zminvd];
    else
        hObj.SelectionHandle.VertexData=...
        [xminvd,xminvd,xmaxvd,xmaxvd,xminvd,xminvd,xmaxvd,xmaxvd;
        yminvd,ymaxvd,yminvd,ymaxvd,yminvd,ymaxvd,yminvd,ymaxvd;
        zminvd,zminvd,zminvd,zminvd,zmaxvd,zmaxvd,zmaxvd,zmaxvd];
    end
    if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
        hObj.SelectionHandle.Visible='on';
    else
        hObj.SelectionHandle.Visible='off';
    end
end
