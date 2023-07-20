function doUpdate(obj,updateState)









    obj.Face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);


    scale=updateState.DevicePixelsPerPoint/updateState.PixelsPerPoint;
    if~isfinite(scale)
        scale=1;
    end
    imdata=obj.getImageData(scale);

    if isempty(imdata)
        obj.Face.Texture=matlab.graphics.primitive.world.Texture.empty;
        obj.Face.ColorData=zeros(2,0,'single');
        obj.Face.ColorType='texturemapped';
        obj.Face.ColorBinding='none';
    else
        it=matlab.graphics.axis.colorspace.IndexColorsIterator;
        it.Colors=reshape(permute(imdata,[2,1,3]),[],size(imdata,3));

        primdata=updateState.ColorSpace.TransformTrueColorToTrueColor(it);

        tex=matlab.graphics.primitive.world.Texture(...
        'ColorType','truecoloralpha',...
        'SamplingFilter','nearest',...
        'CData',reshape(primdata.Data,[4,size(imdata,1),size(imdata,2)]));


        obj.Face.Texture=tex;
        obj.Face.ColorData=single([0,0,1,1;1,0,0,1]);
        obj.Face.ColorType='texturemapped';
        obj.Face.ColorBinding='interpolated';
    end
