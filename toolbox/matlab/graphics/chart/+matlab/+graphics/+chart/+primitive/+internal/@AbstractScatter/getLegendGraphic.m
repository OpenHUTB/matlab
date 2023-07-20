function graphic=getLegendGraphic(hObj)



    graphic=matlab.graphics.primitive.world.Group;
    marker=matlab.graphics.primitive.world.Marker;

    marker.Parent=graphic;
    marker.VertexData=single([.5;.5;0]);
    marker.Size=6;

    marker.LineWidth=hObj.LineWidth;
    hgfilter('MarkerStyleToPrimMarkerStyle',marker,hObj.Marker_I);

    mfc=hObj.MarkerFaceColor;
    mec=hObj.MarkerEdgeColor;


    if isequal(mfc,'flat')


        mfc=hObj.CurrentIconColorInfo.ColorData;
    elseif isequal(hObj.MarkerFaceColor,'auto')

        mfc=hObj.CurrentIconColorInfo.BackgroundColor;
    end


    if isequal(mec,'flat')


        mec=hObj.CurrentIconColorInfo.ColorData;
    end



    hgfilter('FaceColorToMarkerPrimitive',marker,mfc);
    hgfilter('EdgeColorToMarkerPrimitive',marker,mec);


    if numel(marker.FaceColorData)==4&&~strcmp(hObj.MarkerFaceColor,'none')&&...
        ~strcmp(hObj.MarkerFaceAlpha,'flat')
        marker.FaceColorData(4)=uint8(255*hObj.MarkerFaceAlpha);
        if(hObj.MarkerFaceAlpha==1)
            marker.FaceColorType='truecolor';
        else
            marker.FaceColorType='truecoloralpha';
        end
    end


    if numel(marker.EdgeColorData)==4&&~strcmp(hObj.MarkerEdgeColor,'none')&&...
        ~strcmp(hObj.MarkerEdgeAlpha,'flat')
        marker.EdgeColorData(4)=uint8(255*hObj.MarkerEdgeAlpha);
        if(hObj.MarkerEdgeAlpha==1)
            marker.EdgeColorType='truecolor';
        else
            marker.EdgeColorType='truecoloralpha';
        end
    end

end
