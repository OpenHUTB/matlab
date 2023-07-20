function doUpdate(hObj,updateState)







    if isempty(hObj.LineHandle)||~isvalid(hObj.LineHandle)
        return
    end


    if~hObj.Visible
        return
    end


    hasValidData=hObj.isDataValid(false);

    if hasValidData&&(~hObj.LineHandle.Visible||~hObj.HatchHandle.Visible)

        turnVisibility(hObj,"on");
    elseif~hasValidData&&hObj.LineHandle.Visible


        turnVisibility(hObj,"off")
        hObj.isDataValid(true);
    elseif~hasValidData&&~hObj.LineHandle.Visible


        return
    end


    [x,y,z]=hObj.preProcessData(...
    updateState.DataSpace.XScale,...
    updateState.DataSpace.YScale,...
    updateState.DataSpace.XLim,...
    updateState.DataSpace.YLim);


    if updateState.DataSpace.ZScale=="log"
        z(:)=updateState.DataSpace.ZLim(1);
    end



    if(numel(x)<2)||(numel(y)<2)
        turnVisibility(hObj,'off');
        return
    end



    lineVertexData=hObj.calculateLineVertexData(x,y,z);

    worldLineVertexData=matlab.graphics.internal.transformDataToWorld(...
    updateState.DataSpace,updateState.TransformUnderDataSpace,lineVertexData);

    hObj.LineHandle.VertexData=single(worldLineVertexData);
    hObj.LineHandle.StripData=uint32([1,size(worldLineVertexData,2)+1]);
    hObj.LineHandle.LineWidth=hObj.LineWidth;
    hgfilter('RGBAColorToGeometryPrimitive',hObj.LineHandle,hObj.Color);
    hgfilter('LineStyleToPrimLineStyle',hObj.LineHandle,hObj.LineStyle);



    normalizedLineVertexData=matlab.graphics.internal.transformWorldToNormalized(...
    updateState.DataSpace,updateState.TransformUnderDataSpace,worldLineVertexData);


    hObj.calculateHatchSpacing(normalizedLineVertexData);


    if hObj.HatchHandle.Visible
        normalizedHatchVertexData=hObj.calculateHatchVertexData(...
        normalizedLineVertexData,hObj.HatchSpacing_I,hObj.HatchLength_I,hObj.HatchAngle_I);
    else
        normalizedHatchVertexData=[];
    end


    if isempty(normalizedHatchVertexData)
        hObj.HatchHandle.Visible="off";
        hObj.MarkerHandle.Visible="off";
        worldHatchVertexData=[];
    else
        worldHatchVertexData=matlab.graphics.internal.transformNormalizedToWorld(...
        updateState.DataSpace,updateState.TransformUnderDataSpace,normalizedHatchVertexData);

        hObj.HatchHandle.LineWidth=hObj.LineWidth;
        hgfilter('RGBAColorToGeometryPrimitive',hObj.HatchHandle,hObj.Color);
        hgfilter('LineStyleToPrimLineStyle',hObj.HatchHandle,hObj.LineStyle);
    end

    hObj.HatchHandle.VertexData=single(worldHatchVertexData);
    hObj.HatchHandle.StripData=uint32(1:2:size(worldHatchVertexData,2)+1);





    hObj.MarkerHandle.VertexData=hObj.HatchHandle.VertexData;

    if hObj.MarkerHandle.Visible
        if strcmp(hObj.MarkerEdgeColor,'auto')
            mec=hObj.Color_I;
        else
            mec=hObj.MarkerEdgeColor_I;
        end

        if strcmp(hObj.MarkerFaceColor,'auto')
            mfc='none';
        else
            mfc=hObj.MarkerFaceColor_I;
        end

        hgfilter('MarkerStyleToPrimMarkerStyle',hObj.MarkerHandle,hObj.Marker_I);
        hgfilter('FaceColorToMarkerPrimitive',hObj.MarkerHandle,mfc);
        hgfilter('EdgeColorToMarkerPrimitive',hObj.MarkerHandle,mec)
        hObj.MarkerHandle.Size=hObj.MarkerSize_I;
    end




    if hObj.Selected&&hObj.SelectionHighlight
        hObj.SelectionHandle.VertexData=hObj.LineHandle.VertexData;
        hObj.SelectionHandle.Visible='on';
    else
        hObj.SelectionHandle.VertexData=single([]);
        hObj.SelectionHandle.Visible='off';
    end
end

function turnVisibility(hObj,mode)
    hObj.LineHandle.Visible=mode;
    hObj.HatchHandle.Visible=mode;
    hObj.MarkerHandle.Visible=mode;
    hObj.SelectionHandle.Visible=mode;
end