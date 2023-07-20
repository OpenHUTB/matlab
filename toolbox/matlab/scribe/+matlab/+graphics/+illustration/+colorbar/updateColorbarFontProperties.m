function updateColorbarFontProperties(hObj,peerAxes)



    label=hObj.Label_I;
    LabelFontWeight=label.FontWeight_I;
    LabelFontAngle=label.FontAngle;
    LabelFontName=label.FontName;
    LabelFontSize=label.FontSize_I;

    matlab.graphics.illustration.internal.updateFontProperties(hObj,peerAxes);

    if strcmp(label.FontWeightMode,'manual')
        label.FontWeight=LabelFontWeight;
    end
    if strcmp(label.FontAngleMode,'manual')
        label.FontAngle=LabelFontAngle;
    end
    if strcmp(label.FontNameMode,'manual')
        label.FontName=LabelFontName;
    end
    if strcmp(label.FontSizeMode,'manual')
        label.FontSize=LabelFontSize;
    end
