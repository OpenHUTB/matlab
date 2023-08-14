function updateLimitLabelsProperties(hObj)



    labels=[hObj.LabelBig,hObj.LabelMedium,hObj.LabelSmall];
    color=uint8([hObj.TextColor_I'*255;255]);
    font=matlab.graphics.general.Font;
    font.Name=hObj.FontName_I;
    font.Size=hObj.FontSize_I;
    font.Angle=hObj.FontAngle_I;
    font.Weight=hObj.FontWeight_I;
    for i=1:3
        labels(i).ColorData=color;
        labels(i).Interpreter=hObj.Interpreter_I;
        labels(i).Font=font;
    end
end
