function scale=getDPIScale()






    scale=matlab.ui.internal.PositionUtils.getDevicePixelScreenSize()./get(groot,'ScreenSize');
    scale=scale(3);
end