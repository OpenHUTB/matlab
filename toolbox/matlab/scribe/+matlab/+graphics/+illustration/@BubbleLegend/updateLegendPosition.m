function updateLegendPosition(hObj,updateState)




    currPosPoints=updateState.convertUnits('canvas','points',hObj.Units,hObj.Position_I);
    currSizePoints=currPosPoints(3:4);
    minSizePoints=getSize(hObj,updateState);
    newPosPoints=currPosPoints;

    tooNarrow=currSizePoints(1)<minSizePoints(1);
    tooShort=currSizePoints(2)<minSizePoints(2);

    if tooNarrow
        newPosPoints(3)=minSizePoints(1);
    end

    if tooShort
        newPosPoints(4)=minSizePoints(2);
    end

    newPosLegendUnits=updateState.convertUnits('canvas',hObj.Units,'points',newPosPoints);
    hObj.Position_I=newPosLegendUnits;

end

