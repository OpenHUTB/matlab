function traverse=applyThemeValues(obj,themeInfo)








    if obj.EdgeColorMode=="auto"&&isnumeric(obj.EdgeColor)
        obj.EdgeColor_I=themeInfo.EdgeColor;
    end







    traverse=false;

end
