function hints=getHints(hObj)




    varNames=hObj.getChannelDisplayNames(["X","Y","Z"]);
    hints={...
    {'Label','X',convertStringsToChars(varNames(1))},...
    {'Label','Y',convertStringsToChars(varNames(2))},...
    {'Label','Z',convertStringsToChars(varNames(3))}};
    hints=hints(varNames~="");

end
