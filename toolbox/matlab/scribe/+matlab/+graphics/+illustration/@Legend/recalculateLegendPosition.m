function[widthchanged,heightchanged,newPosPoints]=recalculateLegendPosition(hObj,currPosPoints,minSizePoints,orientationChanged,widthMode,heightMode)






    widthchanged=false;
    heightchanged=false;

    newPosPoints=currPosPoints;
    currSizePoints=currPosPoints(3:4);
    tooNarrow=currSizePoints(1)+0.1<minSizePoints(1);
    tooShort=currSizePoints(2)+0.1<minSizePoints(2);
    tooWide=currSizePoints(1)>minSizePoints(1)&&strcmp(widthMode,'auto');
    tooTall=currSizePoints(2)>minSizePoints(2)&&strcmp(heightMode,'auto');
    if tooNarrow||tooWide||(orientationChanged&&strcmp(widthMode,'auto'))
        newPosPoints(1)=hObj.getNewLocation(currPosPoints(1),currPosPoints(3),minSizePoints(1));
        newPosPoints(3)=minSizePoints(1);
        widthchanged=true;
    end
    if tooShort||tooTall||(orientationChanged&&strcmp(heightMode,'auto'))
        newPosPoints(2)=hObj.getNewLocation(currPosPoints(2),currPosPoints(4),minSizePoints(2));
        newPosPoints(4)=minSizePoints(2);
        heightchanged=true;
    end











