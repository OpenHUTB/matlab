function widthInPoints=getCircleSize()





    widthInPixels=8;

    pointsPerInch=72;
    pixelsPerInch=get(0,'ScreenPixelsPerInch');
    pointsPerScreenPixel=pointsPerInch/pixelsPerInch;
    widthInPoints=widthInPixels*pointsPerScreenPixel;

end