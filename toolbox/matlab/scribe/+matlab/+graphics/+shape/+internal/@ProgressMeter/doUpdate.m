function doUpdate(obj,updateState)










    PlayButtonWidth=20;
    ButtonHeight=20;
    BarHeight=6;

    PixelScale=updateState.PixelsPerPoint/updateState.DevicePixelsPerPoint;


    containerLocationInPixels=localConvertDeviceToScaled(...
    updateState.Camera.getDataViewport(),PixelScale);


    objectWidthPixels=containerLocationInPixels(3);
    objectHeightPixels=ButtonHeight;


    bbLocationInPixels=[containerLocationInPixels(1),...
    containerLocationInPixels(2)+containerLocationInPixels(4)-objectHeightPixels];


    vertexData=matlab.graphics.internal.transformViewerToWorld(...
    updateState.Camera,...
    updateState.TransformAboveDataSpace,...
    updateState.DataSpace,...
    updateState.TransformUnderDataSpace,...
    bbLocationInPixels(:));
    anchor=matlab.graphics.internal.transformWorldToData(...
    updateState.DataSpace,...
    updateState.TransformUnderDataSpace,...
    vertexData);
    obj.ControlsContainer.Anchor=anchor;




    obj.ProgressBar.Position=[0,...
    objectHeightPixels-BarHeight,...
    max(0,objectWidthPixels-PlayButtonWidth+1),...
    BarHeight];


    obj.ActionButton.Position=[objectWidthPixels-PlayButtonWidth,...
    0,...
    PlayButtonWidth,...
    ButtonHeight];

end


function pix=localConvertDeviceToScaled(devpix,scale)
    devpix(1:2)=devpix(1:2)-1;
    pix=devpix.*scale;
    pix(1:2)=pix(1:2)+1;
end
