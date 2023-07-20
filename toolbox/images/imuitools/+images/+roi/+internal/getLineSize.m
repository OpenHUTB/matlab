function widthInPoints=getLineSize()





    widthInPixels=3;

    pointsPerInch=72;
    pixelsPerInch=get(0,'ScreenPixelsPerInch');
    pointsPerScreenPixel=pointsPerInch/pixelsPerInch;
    widthInPoints=widthInPixels*pointsPerScreenPixel;

end