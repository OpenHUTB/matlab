function str=varValue2str(varValue)




    displayStruct=matlab.internal.datatoolsservices.getWorkspaceDisplay({varValue});
    str=convertStringsToChars(displayStruct.Value);
end