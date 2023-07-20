function[backgroundColor,foregroundColor]=formatColorStrings(colorJson)
    colorResult=jsondecode(colorJson);
    bgColor=colorResult.BackgroundColor;
    backgroundColor="["+bgColor(1,1)+","+bgColor(2,1)+","+bgColor(3,1)+"]";
    fgColor=colorResult.ForegroundColor;
    foregroundColor="["+fgColor(1,1)+","+fgColor(2,1)+","+fgColor(3,1)+"]";
end