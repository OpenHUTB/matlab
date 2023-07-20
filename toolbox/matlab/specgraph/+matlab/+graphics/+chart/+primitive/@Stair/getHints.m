function hints=getHints(hObj)




    varNames=hObj.getChannelDisplayNames(["X","Y"]);
    hints={...
    {'Label','X',convertStringsToChars(varNames(1))},...
    {'Label','Y',convertStringsToChars(varNames(2))}};
    hints=hints(varNames~="");

end
