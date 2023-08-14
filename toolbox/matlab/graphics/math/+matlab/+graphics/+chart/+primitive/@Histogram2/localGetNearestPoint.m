function index=localGetNearestPoint(hObj,position,isPixel)




    if strcmp(hObj.DisplayStyle,'bar3')
        [x,y,z,isxz,isyz]=hObj.create_bar_coordinates(hObj.XBinEdges,...
        hObj.YBinEdges,hObj.Values,false);
    else
        [x,y,z]=matlab.graphics.chart.primitive.histogram2.internal.create_tile_coordinates(hObj.XBinEdges,...
        hObj.YBinEdges,hObj.Values,false);
    end
    verts=[x(:),y(:),z(:)];


    verts(:,1)=min(max(verts(:,1),hObj.XLimCache(1)),hObj.XLimCache(2));
    verts(:,2)=min(max(verts(:,2),hObj.YLimCache(1)),hObj.YLimCache(2));

    faces=transpose(reshape(1:size(verts,1),4,[]));

    pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

    [vertexindex,faceindex]=pickUtils.nearestFacePoint(hObj,position,isPixel,...
    faces,verts);
    if~isempty(faceindex)
        index=faceindex;
    else
        index=ceil(vertexindex/4);
    end

    if strcmp(hObj.DisplayStyle,'bar3')
        index=localBarFaceIndexToBinIndex(hObj,index,isxz,isyz);
    end

end
