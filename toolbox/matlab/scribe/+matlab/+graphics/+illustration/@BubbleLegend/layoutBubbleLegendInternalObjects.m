function layoutBubbleLegendInternalObjects(hObj,updateState)







    prepBubblesAndLabels(hObj);



    width=getWidthOfLegendInPoints(hObj,updateState);
    height=getHeightInPointsWithoutTitle(hObj);



    dummyFontObj=matlab.graphics.general.Font;
    dummyFontObj.Name=hObj.Title.FontName;
    dummyFontObj.Size=hObj.Title.FontSize;
    dummyFontObj.Angle=hObj.Title.FontAngle;
    dummyFontObj.Weight=hObj.Title.FontWeight;
    textObj.Font=dummyFontObj;
    textObj.String=hObj.Title.String;
    textObj.Interpreter=hObj.Title.Interpreter;
    textObj.FontSmoothing='on';

    [~,titleHeight]=hObj.getLabelSizeInPoints(updateState,textObj);
    if titleHeight~=0
        titleHeight=titleHeight+hObj.Padding/2;
    end
    hObj.positionTitle(height,titleHeight);

    positionBubblesAndLabels(hObj,width,height,titleHeight,updateState);

end