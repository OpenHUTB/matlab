function doUpdate(obj,updateState)









    pos=obj.Position;
    corners=[pos(1),pos(2);...
    pos(1)+pos(3),pos(2);...
    pos(1)+pos(3),pos(2)+pos(4);...
    pos(1),pos(2)+pos(4)];
    iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',corners);
    facevis=obj.Visible;
    try
        vd=TransformPoints(updateState.DataSpace,updateState.TransformUnderDataSpace,iter);
    catch E
        vd=single([0;0;0]);


        facevis='off';
    end
    obj.ButtonFace.VertexData=vd;
    obj.ButtonFace.Visible=facevis;

    if obj.FaceType=="flat"
        faceColor=uint8([241,242,242]);

        obj.ButtonFace.ColorBinding='object';
        colorIter=matlab.graphics.axis.colorspace.IndexColorsIterator('Colors',faceColor);
        colorData=updateState.ColorSpace.TransformTrueColorToTrueColor(colorIter);
        obj.ButtonFace.ColorType=colorData.Type;
        obj.ButtonFace.ColorData=colorData.Data;
    else
        obj.ButtonFace.ColorBinding='none';
    end





    inset=1e-3;
    edgecorners=corners+...
    [inset,inset;...
    -inset,inset;...
    -inset,-inset;
    inset,-inset];
    iter=matlab.graphics.axis.dataspace.IndexPointsIterator('Vertices',edgecorners);
    edgevis=obj.Visible;
    try
        vd=TransformPoints(updateState.DataSpace,updateState.TransformUnderDataSpace,iter);
    catch E
        vd=single([0;0;0]);


        edgevis='off';
    end

    if obj.BorderType=="flat"
        edgeColor=uint8([199,199,199]);
        colorIter=matlab.graphics.axis.colorspace.IndexColorsIterator('Colors',edgeColor);
        colorData=updateState.ColorSpace.TransformTrueColorToTrueColor(colorIter);

        obj.ButtonEdge.ColorBinding='object';
        obj.ButtonEdge.ColorType=colorData.Type;
        obj.ButtonEdge.ColorData=colorData.Data;
        obj.ButtonEdge.VertexData=vd;
        obj.ButtonEdge.StripData=uint32([1,5]);
        obj.ButtonEdge.Visible=edgevis;
    else

        obj.ButtonEdge.Visible='off';
    end


    pad=obj.Padding;
    mtx=makehgtform('translate',pos(1)+pad,pos(2)+pad,0,...
    'scale',[pos(3)-2*pad,pos(4)-2*pad,1]);
    obj.ContentContainer.Matrix=mtx;
end
